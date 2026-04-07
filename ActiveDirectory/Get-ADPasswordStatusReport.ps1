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
