<#
.SYNOPSIS
Exports Active Directory user information for reporting purposes.

.DESCRIPTION
This script retrieves user data from Active Directory and exports the results
for administrative review and operational reporting.

.EXAMPLE
.\Export-ADUserReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module ActiveDirectory

Write-Host "Retrieving Active Directory users..." -ForegroundColor Cyan

$users = Get-ADUser -Filter * -Properties DisplayName, EmailAddress, Department, Title, Manager, WhenCreated, LastLogonDate, Enabled |
    Select-Object SamAccountName, DisplayName, EmailAddress, Department, Title, Manager, WhenCreated, LastLogonDate, Enabled |
    Sort-Object DisplayName

if ($users.Count -eq 0) {
    Write-Host "No users found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($users.Count) user(s)." -ForegroundColor Green
    $users | Format-Table -AutoSize
}
