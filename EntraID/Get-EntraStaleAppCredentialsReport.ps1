<#
.SYNOPSIS
Reports on stale Microsoft Entra application credentials.

.DESCRIPTION
This script retrieves application registrations and reports expired or soon-to-
expire secrets and certificates for credential hygiene review.

.PARAMETER DaysUntilExpiry
Number of days to look ahead for expiring credentials. Default is 30.

.EXAMPLE
.\Get-EntraStaleAppCredentialsReport.ps1 -DaysUntilExpiry 30

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
param (
    [Parameter()]
    [int]$DaysUntilExpiry = 30
)

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
Connect-MgGraph -Scopes "Application.Read.All" -NoWelcome

$cutoffDate = (Get-Date).AddDays($DaysUntilExpiry)
Write-Host "Retrieving application credentials..." -ForegroundColor Cyan
$applications = Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/applications?`$select=id,displayName,appId,passwordCredentials,keyCredentials"

$report = foreach ($app in $applications) {
    foreach ($secret in @($app.passwordCredentials)) {
        $status = if ($secret.endDateTime -lt (Get-Date)) { 'Expired' } elseif ($secret.endDateTime -lt $cutoffDate) { 'Expiring Soon' } else { 'Valid' }
        [PSCustomObject]@{
            AppName        = $app.displayName
            AppId          = $app.appId
            CredentialType = 'Secret'
            Description    = $secret.displayName
            EndDateTime    = $secret.endDateTime
            Status         = $status
        }
    }
    foreach ($cert in @($app.keyCredentials)) {
        $status = if ($cert.endDateTime -lt (Get-Date)) { 'Expired' } elseif ($cert.endDateTime -lt $cutoffDate) { 'Expiring Soon' } else { 'Valid' }
        [PSCustomObject]@{
            AppName        = $app.displayName
            AppId          = $app.appId
            CredentialType = 'Certificate'
            Description    = $cert.displayName
            EndDateTime    = $cert.endDateTime
            Status         = $status
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No application credentials found." -ForegroundColor Yellow
}
else {
    $expired = ($report | Where-Object { $_.Status -eq 'Expired' }).Count
    $expiringSoon = ($report | Where-Object { $_.Status -eq 'Expiring Soon' }).Count
    Write-Host "Found $($report.Count) credential record(s). Expired: $expired, Expiring soon: $expiringSoon" -ForegroundColor Green
    $report | Sort-Object Status, EndDateTime | Format-Table -AutoSize
}
