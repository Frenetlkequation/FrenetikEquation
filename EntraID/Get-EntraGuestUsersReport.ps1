<#
.SYNOPSIS
Reports on Entra ID guest user accounts.

.DESCRIPTION
This script identifies guest (external) user accounts in Entra ID and reports
their status, creation date, and last sign-in activity for security review
and tenant hygiene.

.EXAMPLE
.\Get-EntraGuestUsersReport.ps1

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

#Requires -Module Microsoft.Graph.Users

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

Write-Host "Retrieving guest users from Entra ID..." -ForegroundColor Cyan

$guests = Get-MgUser -Filter "userType eq 'Guest'" -All -Property Id, DisplayName, UserPrincipalName, Mail, CreatedDateTime, AccountEnabled, SignInActivity, ExternalUserState |
    Select-Object Id, DisplayName, UserPrincipalName, Mail, CreatedDateTime, AccountEnabled, ExternalUserState,
        @{Name = "LastSignIn"; Expression = { $_.SignInActivity.LastSignInDateTime }},
        @{Name = "DaysSinceLastSignIn"; Expression = {
            if ($_.SignInActivity.LastSignInDateTime) {
                [math]::Round(((Get-Date) - $_.SignInActivity.LastSignInDateTime).TotalDays, 0)
            } else { "Never" }
        }} |
    Sort-Object LastSignIn

if ($guests.Count -eq 0) {
    Write-Host "No guest users found." -ForegroundColor Green
}
else {
    $neverSignedIn = ($guests | Where-Object { $_.DaysSinceLastSignIn -eq "Never" }).Count
    $pendingAcceptance = ($guests | Where-Object { $_.ExternalUserState -eq "PendingAcceptance" }).Count

    Write-Host "Found $($guests.Count) guest user(s)." -ForegroundColor Green
    Write-Host "  Never signed in: $neverSignedIn" -ForegroundColor Yellow
    Write-Host "  Pending acceptance: $pendingAcceptance" -ForegroundColor Yellow
    $guests | Format-Table -AutoSize
}
