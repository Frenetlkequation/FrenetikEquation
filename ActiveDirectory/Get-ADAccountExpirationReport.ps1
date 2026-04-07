<#
.SYNOPSIS
Reports on Active Directory account expiration dates.

.DESCRIPTION
This script identifies user and computer accounts that are expired or nearing
expiration so account lifecycle actions can be taken in advance.

.PARAMETER DaysUntilExpiry
Number of days ahead to flag accounts as expiring soon. Default is 30.

.EXAMPLE
.\Get-ADAccountExpirationReport.ps1 -DaysUntilExpiry 14

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

Write-Host "Retrieving expiring Active Directory accounts..." -ForegroundColor Cyan

$userReport = Get-ADUser -Filter * -Properties AccountExpirationDate, Enabled |
    Where-Object { $_.AccountExpirationDate } |
    ForEach-Object {
        $status = if ($_.AccountExpirationDate -lt $today) { "Expired" }
                  elseif ($_.AccountExpirationDate -lt $threshold) { "Expiring Soon" }
                  else { "Valid" }
        [PSCustomObject]@{
            ObjectType          = "User"
            SamAccountName      = $_.SamAccountName
            DisplayName         = $_.DisplayName
            AccountExpirationDate = $_.AccountExpirationDate
            Status              = $status
            Enabled             = $_.Enabled
        }
    }

$computerReport = Get-ADComputer -Filter * -Properties AccountExpirationDate, Enabled, OperatingSystem |
    Where-Object { $_.AccountExpirationDate } |
    ForEach-Object {
        $status = if ($_.AccountExpirationDate -lt $today) { "Expired" }
                  elseif ($_.AccountExpirationDate -lt $threshold) { "Expiring Soon" }
                  else { "Valid" }
        [PSCustomObject]@{
            ObjectType          = "Computer"
            SamAccountName      = $_.SamAccountName
            DisplayName         = $_.Name
            AccountExpirationDate = $_.AccountExpirationDate
            Status              = $status
            Enabled             = $_.Enabled
        }
    }

$report = @($userReport + $computerReport) | Sort-Object Status, AccountExpirationDate, SamAccountName

if ($report.Count -eq 0) {
    Write-Host "No expiring accounts found." -ForegroundColor Green
}
else {
    $expired = ($report | Where-Object { $_.Status -eq "Expired" }).Count
    $expiringSoon = ($report | Where-Object { $_.Status -eq "Expiring Soon" }).Count
    Write-Host "Retrieved $($report.Count) expiring account(s)." -ForegroundColor Green
    Write-Host "  Expired: $expired" -ForegroundColor Red
    Write-Host "  Expiring within $DaysUntilExpiry days: $expiringSoon" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
