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

Disclaimer:
Test this script in a non-production environment before using it in production.
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
