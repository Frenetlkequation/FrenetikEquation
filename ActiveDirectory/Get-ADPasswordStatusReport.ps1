<#
.SYNOPSIS
Reports on Active Directory user password status.

.DESCRIPTION
This script retrieves password-related attributes for Active Directory users,
including password last set date, expiration status, and accounts with
passwords set to never expire. Useful for security auditing and compliance.

.EXAMPLE
.\Get-ADPasswordStatusReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module ActiveDirectory

Write-Host "Retrieving Active Directory password status information..." -ForegroundColor Cyan

$defaultPolicy = Get-ADDefaultDomainPasswordPolicy
$maxPasswordAge = $defaultPolicy.MaxPasswordAge

$users = Get-ADUser -Filter { Enabled -eq $true } -Properties DisplayName, PasswordLastSet, PasswordNeverExpires, PasswordExpired, LockedOut, LastLogonDate |
    ForEach-Object {
        $expiryDate = if ($_.PasswordNeverExpires -or $maxPasswordAge.TotalDays -eq 0) {
            "Never"
        }
        elseif ($_.PasswordLastSet) {
            ($_.PasswordLastSet + $maxPasswordAge).ToString("yyyy-MM-dd")
        }
        else {
            "Not Set"
        }

        [PSCustomObject]@{
            SamAccountName       = $_.SamAccountName
            DisplayName          = $_.DisplayName
            PasswordLastSet      = $_.PasswordLastSet
            PasswordExpires      = $expiryDate
            PasswordNeverExpires = $_.PasswordNeverExpires
            PasswordExpired      = $_.PasswordExpired
            LockedOut            = $_.LockedOut
            LastLogonDate        = $_.LastLogonDate
        }
    } | Sort-Object PasswordLastSet

if ($users.Count -eq 0) {
    Write-Host "No users found." -ForegroundColor Yellow
}
else {
    $neverExpires = ($users | Where-Object { $_.PasswordNeverExpires -eq $true }).Count
    $expired = ($users | Where-Object { $_.PasswordExpired -eq $true }).Count
    $lockedOut = ($users | Where-Object { $_.LockedOut -eq $true }).Count

    Write-Host "Retrieved $($users.Count) user(s)." -ForegroundColor Green
    Write-Host "  Password never expires: $neverExpires" -ForegroundColor Yellow
    Write-Host "  Password expired: $expired" -ForegroundColor Yellow
    Write-Host "  Locked out: $lockedOut" -ForegroundColor Yellow
    $users | Format-Table -AutoSize
}
