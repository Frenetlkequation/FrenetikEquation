<#
.SYNOPSIS
Reports on recently created Active Directory user accounts.

.DESCRIPTION
This script identifies user accounts created within a configurable time window
for onboarding review and security auditing.

.PARAMETER DaysBack
Number of days back to include. Default is 30.

.EXAMPLE
.\Get-ADRecentlyCreatedUsersReport.ps1 -DaysBack 14

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
    [int]$DaysBack = 30
)

#Requires -Module ActiveDirectory

$cutoff = (Get-Date).AddDays(-$DaysBack)

Write-Host "Retrieving recently created Active Directory users..." -ForegroundColor Cyan

$report = Get-ADUser -Filter * -Properties WhenCreated, Enabled, LastLogonDate, Department |
    Where-Object { $_.WhenCreated -ge $cutoff } |
    Select-Object SamAccountName, DisplayName, Department, Enabled, WhenCreated, LastLogonDate |
    Sort-Object WhenCreated -Descending

if ($report.Count -eq 0) {
    Write-Host "No recently created users found." -ForegroundColor Green
}
else {
    Write-Host "Found $($report.Count) recently created user(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
