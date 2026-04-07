<#
.SYNOPSIS
Reports on Active Directory user password expiration forecasts.

.DESCRIPTION
This script retrieves Active Directory users and estimates password expiry
dates to help identify accounts that are expired or nearing expiration.

.PARAMETER DaysUntilExpiry
Number of days ahead to flag passwords as expiring soon. Default is 30.

.EXAMPLE
.\Get-ADUserPasswordExpiryForecastReport.ps1 -DaysUntilExpiry 45

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
param (
    [Parameter()]
    [int]$DaysUntilExpiry = 30
)

#Requires -Module ActiveDirectory

$today = Get-Date
$threshold = $today.AddDays($DaysUntilExpiry)

Write-Host "Retrieving Active Directory users for password expiry forecasting..." -ForegroundColor Cyan

$users = Get-ADUser -Filter * -Properties PasswordLastSet, PasswordNeverExpires, PasswordExpired, msDS-UserPasswordExpiryTimeComputed, Enabled, LastLogonDate |
    Sort-Object SamAccountName

$report = foreach ($user in $users) {
    $expiryDate = $null
    if ($user.'msDS-UserPasswordExpiryTimeComputed' -and $user.'msDS-UserPasswordExpiryTimeComputed' -gt 0) {
        $expiryDate = [datetime]::FromFileTime([int64]$user.'msDS-UserPasswordExpiryTimeComputed')
    }

    $status = if ($user.PasswordNeverExpires) { "Never Expires" }
              elseif ($user.PasswordExpired) { "Expired" }
              elseif ($expiryDate -and $expiryDate -lt $threshold) { "Expiring Soon" }
              else { "Valid" }

    [PSCustomObject]@{
        SamAccountName     = $user.SamAccountName
        DisplayName        = $user.DisplayName
        Enabled            = $user.Enabled
        PasswordLastSet    = $user.PasswordLastSet
        PasswordExpiryDate = $expiryDate
        DaysRemaining      = if ($expiryDate) { [math]::Round(($expiryDate - $today).TotalDays, 0) } else { $null }
        Status             = $status
        LastLogonDate      = $user.LastLogonDate
    }
}

if ($report.Count -eq 0) {
    Write-Host "No user accounts found." -ForegroundColor Yellow
}
else {
    $expired = ($report | Where-Object { $_.Status -eq "Expired" }).Count
    $expiringSoon = ($report | Where-Object { $_.Status -eq "Expiring Soon" }).Count

    Write-Host "Retrieved $($report.Count) user password record(s)." -ForegroundColor Green
    Write-Host "  Expired: $expired" -ForegroundColor Yellow
    Write-Host "  Expiring within $DaysUntilExpiry days: $expiringSoon" -ForegroundColor Yellow
    $report | Sort-Object Status, DaysRemaining, SamAccountName | Format-Table -AutoSize
}
