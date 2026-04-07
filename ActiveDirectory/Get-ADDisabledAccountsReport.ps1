<#
.SYNOPSIS
Reports on disabled Active Directory computer and user accounts.

.DESCRIPTION
This script identifies disabled computer and user accounts in Active Directory
for cleanup planning and security auditing purposes.

.EXAMPLE
.\Get-ADDisabledAccountsReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module ActiveDirectory

Write-Host "Retrieving disabled accounts from Active Directory..." -ForegroundColor Cyan

$disabledUsers = Get-ADUser -Filter { Enabled -eq $false } -Properties DisplayName, WhenCreated, LastLogonDate, Description, DistinguishedName |
    Select-Object SamAccountName, DisplayName, WhenCreated, LastLogonDate, Description, DistinguishedName |
    Sort-Object LastLogonDate

$disabledComputers = Get-ADComputer -Filter { Enabled -eq $false } -Properties WhenCreated, LastLogonDate, Description, OperatingSystem |
    Select-Object Name, OperatingSystem, WhenCreated, LastLogonDate, Description |
    Sort-Object LastLogonDate

Write-Host "`n--- Disabled User Accounts ---" -ForegroundColor Yellow
if ($disabledUsers.Count -eq 0) {
    Write-Host "No disabled user accounts found." -ForegroundColor Green
}
else {
    Write-Host "Found $($disabledUsers.Count) disabled user account(s)." -ForegroundColor Yellow
    $disabledUsers | Format-Table -AutoSize
}

Write-Host "`n--- Disabled Computer Accounts ---" -ForegroundColor Yellow
if ($disabledComputers.Count -eq 0) {
    Write-Host "No disabled computer accounts found." -ForegroundColor Green
}
else {
    Write-Host "Found $($disabledComputers.Count) disabled computer account(s)." -ForegroundColor Yellow
    $disabledComputers | Format-Table -AutoSize
}
