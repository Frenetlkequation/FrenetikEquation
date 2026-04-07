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
