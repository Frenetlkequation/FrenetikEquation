<#
.SYNOPSIS
Exports Entra ID user information for reporting purposes.

.DESCRIPTION
This script retrieves user data from Entra ID and exports the results
for administrative review and operational reporting.

.EXAMPLE
.\Export-EntraUsers.ps1

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

Write-Host "Retrieving Entra ID users..." -ForegroundColor Cyan

$users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, Mail, JobTitle, Department, AccountEnabled, CreatedDateTime, SignInActivity |
    Select-Object Id, DisplayName, UserPrincipalName, Mail, JobTitle, Department, AccountEnabled, CreatedDateTime,
        @{Name = "LastSignIn"; Expression = { $_.SignInActivity.LastSignInDateTime }} |
    Sort-Object DisplayName

if ($users.Count -eq 0) {
    Write-Host "No users found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($users.Count) user(s)." -ForegroundColor Green
    $users | Format-Table -AutoSize
}
