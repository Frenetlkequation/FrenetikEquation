<#
.SYNOPSIS
Reports on Microsoft Entra Conditional Access coverage.

.DESCRIPTION
This script retrieves Conditional Access policies and summarizes coverage
across users, applications, and policy states for security governance.

.EXAMPLE
.\Get-EntraConditionalAccessCoverageReport.ps1

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
Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

Write-Host "Retrieving Conditional Access policies..." -ForegroundColor Cyan
$policies = Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"

$report = foreach ($policy in $policies) {
    $includeUsers = @($policy.conditions.users.includeUsers)
    $includeApps = @($policy.conditions.applications.includeApplications)
    $platforms = @($policy.conditions.platforms.includePlatforms)
    [PSCustomObject]@{
        PolicyName   = $policy.displayName
        State        = $policy.state
        IncludeUsers = if ($includeUsers.Count) { $includeUsers -join ', ' } else { 'None' }
        IncludeApps  = if ($includeApps.Count) { $includeApps -join ', ' } else { 'None' }
        Platforms    = if ($platforms.Count) { $platforms -join ', ' } else { 'All' }
        GrantControls = if ($policy.grantControls.builtInControls) { $policy.grantControls.builtInControls -join ', ' } else { 'None' }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Conditional Access policies found." -ForegroundColor Yellow
}
else {
    $enabled = ($report | Where-Object { $_.State -eq 'enabled' }).Count
    $reportOnly = ($report | Where-Object { $_.State -eq 'enabledForReportingButNotEnforced' }).Count
    Write-Host "Retrieved $($report.Count) Conditional Access policy(ies). Enabled: $enabled, Report-only: $reportOnly" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
