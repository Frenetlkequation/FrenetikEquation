<#
.SYNOPSIS
Reports on Entra ID MFA registration status.

.DESCRIPTION
This script retrieves the Entra ID authentication method registration report
and summarizes whether users have MFA registered, which methods are present,
and when the registration state was last updated.

.EXAMPLE
.\Get-EntraMFARegistrationReport.ps1

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

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Reports.Read.All" -NoWelcome

Write-Host "Retrieving MFA registration details..." -ForegroundColor Cyan

function Get-GraphCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Uri
    )

    $items = @()
    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType PSObject
        if ($response.value) {
            $items += $response.value
        }
        $Uri = $response.'@odata.nextLink'
    } while ($Uri)

    return $items
}

$report = Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/reports/authenticationMethods/userRegistrationDetails" |
    Select-Object userDisplayName, userPrincipalName,
        @{Name = "MFARegistered"; Expression = { [bool]$_.isMfaRegistered }},
        @{Name = "PasswordlessCapable"; Expression = { [bool]$_.isPasswordlessCapable }},
        @{Name = "SSPREnabled"; Expression = { [bool]$_.isSsprEnabled }},
        @{Name = "SSPRRegistered"; Expression = { [bool]$_.isSsprRegistered }},
        @{Name = "MethodsRegistered"; Expression = { if ($_.methodsRegistered) { $_.methodsRegistered -join "; " } else { "None" } }},
        @{Name = "DefaultMFA"; Expression = { if ($_.defaultMfaMethod) { $_.defaultMfaMethod } else { "None" } }},
        lastUpdatedDateTime |
    Sort-Object MFARegistered, userDisplayName

if ($report.Count -eq 0) {
    Write-Host "No MFA registration records found." -ForegroundColor Yellow
}
else {
    $mfaRegistered = ($report | Where-Object { $_.MFARegistered }).Count
    $notRegistered = ($report | Where-Object { -not $_.MFARegistered }).Count

    Write-Host "Retrieved $($report.Count) MFA registration record(s)." -ForegroundColor Green
    Write-Host "  MFA registered: $mfaRegistered" -ForegroundColor Yellow
    Write-Host "  MFA not registered: $notRegistered" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
