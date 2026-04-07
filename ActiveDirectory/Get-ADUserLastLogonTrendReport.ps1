<#
.SYNOPSIS
Reports on Active Directory user last logon trends.

.DESCRIPTION
This script groups Active Directory users by last logon recency to help
identify active, stale, and inactive accounts.

.PARAMETER DaysInactive
Number of days without logon before a user is flagged as inactive. Default is 90.

.EXAMPLE
.\Get-ADUserLastLogonTrendReport.ps1 -DaysInactive 120

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
    [int]$DaysInactive = 90
)

#Requires -Module ActiveDirectory

$today = Get-Date
$cutoff = $today.AddDays(-$DaysInactive)

Write-Host "Retrieving Active Directory users for last logon trend reporting..." -ForegroundColor Cyan

$users = Get-ADUser -Filter * -Properties LastLogonDate, Enabled, WhenCreated, PasswordLastSet |
    Sort-Object LastLogonDate

$report = foreach ($user in $users) {
    $daysSinceLastLogon = if ($user.LastLogonDate) { [math]::Round(($today - $user.LastLogonDate).TotalDays, 0) } else { "Never" }
    $bucket = if ($daysSinceLastLogon -eq "Never") { "Never" }
              elseif ($daysSinceLastLogon -le 7) { "0-7 Days" }
              elseif ($daysSinceLastLogon -le 30) { "8-30 Days" }
              elseif ($daysSinceLastLogon -le 90) { "31-90 Days" }
              else { "91+ Days" }

    [PSCustomObject]@{
        SamAccountName    = $user.SamAccountName
        DisplayName       = $user.DisplayName
        Enabled           = $user.Enabled
        WhenCreated       = $user.WhenCreated
        LastLogonDate     = $user.LastLogonDate
        DaysSinceLastLogon = $daysSinceLastLogon
        TrendBucket       = $bucket
        Inactive          = if ($user.LastLogonDate) { $user.LastLogonDate -lt $cutoff } else { $true }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No user accounts found." -ForegroundColor Yellow
}
else {
    $inactive = ($report | Where-Object { $_.Inactive }).Count
    Write-Host "Retrieved $($report.Count) user trend record(s). Inactive: $inactive" -ForegroundColor Green
    $report | Sort-Object TrendBucket, SamAccountName | Format-Table -AutoSize
}
