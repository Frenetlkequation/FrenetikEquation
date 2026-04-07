<#
.SYNOPSIS
Reports on Entra ID directory audit events.

.DESCRIPTION
This script retrieves directory audit events from Microsoft Entra ID and
reports activity, actor, targets, and result for audit review.

.EXAMPLE
.\Get-EntraDirectoryAuditReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied,
    including but not limited to the warranties of merchantability, fitness for a
    particular purpose, and noninfringement.

    In no event shall the authors, contributors, or copyright holders (FrenetikEquation)
    be liable for any claim, damages, or other liability, whether in an action of
    contract, tort, or otherwise, arising from, out of, or in connection with this
    script or the use or other dealings in this script. This includes, without
    limitation, any direct, indirect, incidental, special, exemplary, or consequential
    damages, including but not limited to loss of data, loss of revenue, business
    interruption, or damage to systems.

    USE AT YOUR OWN RISK. You are solely responsible for testing this script in a
    non-production environment before deploying to any production system. The user
    assumes all responsibility and risk for the use of this script. It is strongly
    recommended that you review, understand, and validate the script logic before
    execution.

    By using this script, you acknowledge and agree to these terms. If you do not
    agree, do not use this script. Refer to the LICENSE file in the root of this
    repository for the full license terms.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

function Invoke-GraphRequestJson {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Uri)

    $response = Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType HttpResponseMessage
    $content = $response.Content.ReadAsStringAsync().Result
    if ([string]::IsNullOrWhiteSpace($content)) { return $null }
    $content | ConvertFrom-Json -Depth 20
}

function Get-GraphCollection {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Uri)

    $items = @()
    do {
        $payload = Invoke-GraphRequestJson -Uri $Uri
        if ($null -ne $payload.value) { $items += @($payload.value) } elseif ($null -ne $payload) { $items += @($payload) }
        $Uri = $payload.'@odata.nextLink'
    } while ($Uri)
    $items
}

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "AuditLog.Read.All" -NoWelcome

Write-Host "Retrieving directory audit events..." -ForegroundColor Cyan
$report = Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?`$select=activityDateTime,activityDisplayName,category,initiatedBy,targetResources,result,correlationId" |
    ForEach-Object {
        $initiatedBy = if ($_.initiatedBy.user.userPrincipalName) { $_.initiatedBy.user.userPrincipalName } elseif ($_.initiatedBy.app.displayName) { $_.initiatedBy.app.displayName } else { 'Unknown' }
        $targets = if ($_.targetResources) { ($_.targetResources | ForEach-Object { $_.displayName }) -join '; ' } else { 'None' }
        [PSCustomObject]@{
            ActivityDateTime    = $_.activityDateTime
            ActivityDisplayName = $_.activityDisplayName
            Category            = $_.category
            InitiatedBy         = $initiatedBy
            TargetResources     = $targets
            Result              = $_.result
            CorrelationId       = $_.correlationId
        }
    }

if ($report.Count -eq 0) {
    Write-Host "No directory audit events found." -ForegroundColor Green
}
else {
    $failed = ($report | Where-Object { $_.Result -ne 'success' }).Count
    Write-Host "Found $($report.Count) directory audit event(s). Non-success results: $failed" -ForegroundColor Yellow
    $report | Sort-Object ActivityDateTime -Descending | Format-Table -AutoSize
}
