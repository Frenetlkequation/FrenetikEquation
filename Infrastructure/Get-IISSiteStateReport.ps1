<#
.SYNOPSIS
Reports on IIS site state.

.DESCRIPTION
This script inventories IIS site state and availability for operations review.

.EXAMPLE
.\Get-IISSiteStateReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module WebAdministration

Import-Module WebAdministration -ErrorAction SilentlyContinue

Write-Host "Retrieving IIS site state..." -ForegroundColor Cyan

$report = Get-Website -ErrorAction SilentlyContinue | Select-Object Name, State, PhysicalPath, ID

if ($report.Count -eq 0) {
    Write-Host "No IIS site state data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS site state record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
