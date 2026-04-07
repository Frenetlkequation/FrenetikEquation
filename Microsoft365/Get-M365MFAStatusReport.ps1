<#
.SYNOPSIS
Reports on Microsoft 365 MFA registration status for all users.

.DESCRIPTION
This script checks MFA registration status across Microsoft 365 users,
identifying accounts without MFA configured for security compliance.

.EXAMPLE
.\Get-M365MFAStatusReport.ps1

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

#Requires -Module Microsoft.Graph.Reports
#Requires -Module Microsoft.Graph.Users

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "UserAuthenticationMethod.Read.All", "User.Read.All" -NoWelcome

Write-Host "Retrieving user authentication methods..." -ForegroundColor Cyan

$users = Get-MgUser -All -Filter "userType eq 'Member'" -Property Id, DisplayName, UserPrincipalName, AccountEnabled

$report = foreach ($user in $users) {
    if (-not $user.AccountEnabled) { continue }

    $methods = Get-MgUserAuthenticationMethod -UserId $user.Id -ErrorAction SilentlyContinue

    $methodTypes = $methods | ForEach-Object {
        $_.AdditionalProperties["@odata.type"] -replace "#microsoft.graph.", ""
    }

    $hasMFA = ($methodTypes | Where-Object {
        $_ -in @("microsoftAuthenticatorAuthenticationMethod",
                  "phoneAuthenticationMethod",
                  "fido2AuthenticationMethod",
                  "softwareOathAuthenticationMethod",
                  "temporaryAccessPassAuthenticationMethod",
                  "windowsHelloForBusinessAuthenticationMethod")
    }).Count -gt 0

    [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        MFAEnabled        = $hasMFA
        MethodCount       = $methods.Count
        Methods           = ($methodTypes -join ", ")
    }
}

if ($report.Count -eq 0) {
    Write-Host "No users found." -ForegroundColor Yellow
}
else {
    $noMFA = ($report | Where-Object { -not $_.MFAEnabled }).Count
    Write-Host "Checked $($report.Count) user(s). Without MFA: $noMFA" -ForegroundColor Green
    if ($noMFA -gt 0) {
        Write-Host "WARNING: $noMFA user(s) do not have MFA configured." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
