<#
.SYNOPSIS
Reports on UPS status.

.DESCRIPTION
This script inventories battery-backed power or UPS status on the local computer.

.EXAMPLE
.\Get-UPSStatusReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving UPS / battery status..." -ForegroundColor Cyan

$report = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name      = $_.Name
        Status    = $_.BatteryStatus
        EstimatedChargeRemaining = $_.EstimatedChargeRemaining
        TimeRemaining = $_.TimeRemaining
    }
}

if ($report.Count -eq 0) {
    Write-Host "No UPS or battery data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) UPS / battery record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
