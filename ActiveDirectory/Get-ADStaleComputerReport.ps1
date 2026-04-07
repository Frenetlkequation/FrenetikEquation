<#
.SYNOPSIS
Reports on stale Active Directory computer accounts.

.DESCRIPTION
This script identifies computer accounts in Active Directory that have not
logged on within the configured inactivity threshold for cleanup planning and
security auditing purposes.

.PARAMETER DaysInactive
Number of days since last logon to flag a computer as stale. Default is 90.

.EXAMPLE
.\Get-ADStaleComputerReport.ps1 -DaysInactive 60

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

$cutoffDate = (Get-Date).AddDays(-$DaysInactive)

Write-Host "Retrieving stale computer accounts..." -ForegroundColor Cyan

$computers = Get-ADComputer -Filter * -Properties OperatingSystem, LastLogonDate, WhenCreated, Enabled, Description, DistinguishedName |
    Select-Object Name, OperatingSystem, LastLogonDate, WhenCreated, Enabled, Description,
        @{Name = "Stale"; Expression = {
            if ($_.LastLogonDate) { $_.LastLogonDate -lt $cutoffDate } else { $true }
        }},
        @{Name = "OU"; Expression = { ($_.DistinguishedName -split ",", 2)[1] }} |
    Sort-Object LastLogonDate

$report = $computers | Where-Object { $_.Stale }

if ($report.Count -eq 0) {
    Write-Host "No stale computer accounts found." -ForegroundColor Green
}
else {
    $enabled = ($report | Where-Object { $_.Enabled }).Count
    $disabled = ($report | Where-Object { -not $_.Enabled }).Count

    Write-Host "Retrieved $($report.Count) stale computer account(s)." -ForegroundColor Green
    Write-Host "  Enabled: $enabled" -ForegroundColor Yellow
    Write-Host "  Disabled: $disabled" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
