<#
.SYNOPSIS
Identifies inactive user accounts in Active Directory.

.DESCRIPTION
This script queries Active Directory for user accounts that have not logged in
within a specified number of days. Results are displayed for security auditing
and account cleanup purposes.

.PARAMETER DaysInactive
Number of days since last logon to consider a user inactive. Default is 90.

.EXAMPLE
.\Audit-InactiveUsers.ps1 -DaysInactive 90

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [int]$DaysInactive = 90
)

#Requires -Module ActiveDirectory

$cutoffDate = (Get-Date).AddDays(-$DaysInactive)

Write-Host "Searching for users inactive for more than $DaysInactive days (last logon before $cutoffDate)..." -ForegroundColor Cyan

$inactiveUsers = Get-ADUser -Filter {
    LastLogonDate -lt $cutoffDate -and Enabled -eq $true
} -Properties LastLogonDate, DisplayName, EmailAddress, Department, WhenCreated |
    Select-Object SamAccountName, DisplayName, EmailAddress, Department, LastLogonDate, WhenCreated, Enabled |
    Sort-Object LastLogonDate

if ($inactiveUsers.Count -eq 0) {
    Write-Host "No inactive users found." -ForegroundColor Green
}
else {
    Write-Host "Found $($inactiveUsers.Count) inactive user(s):" -ForegroundColor Yellow
    $inactiveUsers | Format-Table -AutoSize
}
