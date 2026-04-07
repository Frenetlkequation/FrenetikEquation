<#
.SYNOPSIS
Reports on inactive Active Directory computers by OU.

.DESCRIPTION
This script identifies inactive computer accounts and groups them by OU path
to help target cleanup and review efforts.

.PARAMETER DaysInactive
Number of days since last logon to flag a computer as inactive. Default is 90.

.EXAMPLE
.\Get-ADInactiveComputersByOUReport.ps1 -DaysInactive 120

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

$cutoff = (Get-Date).AddDays(-$DaysInactive)

Write-Host "Retrieving inactive computers and grouping by OU..." -ForegroundColor Cyan

$report = Get-ADComputer -Filter * -Properties LastLogonDate, Enabled, DistinguishedName, OperatingSystem |
    Where-Object { -not $_.LastLogonDate -or $_.LastLogonDate -lt $cutoff } |
    Select-Object Name, OperatingSystem, Enabled,
        @{Name = "OU"; Expression = { ($_.DistinguishedName -split ",", 2)[1] }},
        LastLogonDate |
    Sort-Object OU, Name

if ($report.Count -eq 0) {
    Write-Host "No inactive computers found." -ForegroundColor Green
}
else {
    Write-Host "Found $($report.Count) inactive computer(s)." -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
