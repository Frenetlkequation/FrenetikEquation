<#
.SYNOPSIS
Reports on Active Directory computer accounts.

.DESCRIPTION
This script retrieves computer accounts from Active Directory including
operating system, last logon date, and enabled status for inventory
and security auditing purposes.

.PARAMETER DaysInactive
Number of days since last logon to flag a computer as inactive. Default is 90.

.EXAMPLE
.\Get-ADComputerReport.ps1 -DaysInactive 60

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

Write-Host "Retrieving Active Directory computer accounts..." -ForegroundColor Cyan

$computers = Get-ADComputer -Filter * -Properties DisplayName, OperatingSystem, OperatingSystemVersion, LastLogonDate, WhenCreated, Enabled, IPv4Address, DistinguishedName |
    Select-Object Name, DisplayName, OperatingSystem, OperatingSystemVersion, IPv4Address, LastLogonDate, WhenCreated, Enabled,
        @{Name = "Inactive"; Expression = { if ($_.LastLogonDate -and $_.LastLogonDate -lt $cutoffDate) { $true } elseif (-not $_.LastLogonDate) { $true } else { $false } }},
        @{Name = "OU"; Expression = { ($_.DistinguishedName -split ",", 2)[1] }} |
    Sort-Object OperatingSystem, Name

if ($computers.Count -eq 0) {
    Write-Host "No computer accounts found." -ForegroundColor Yellow
}
else {
    $inactive = ($computers | Where-Object { $_.Inactive }).Count
    $disabled = ($computers | Where-Object { -not $_.Enabled }).Count

    Write-Host "Retrieved $($computers.Count) computer account(s)." -ForegroundColor Green
    Write-Host "  Inactive (>$DaysInactive days): $inactive" -ForegroundColor Yellow
    Write-Host "  Disabled: $disabled" -ForegroundColor Yellow
    $computers | Format-Table -AutoSize
}
