<#
.SYNOPSIS
Reports on print drivers.

.DESCRIPTION
This script inventories installed print drivers for print server administration.

.EXAMPLE
.\Get-PrintDriverInventoryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving print drivers..." -ForegroundColor Cyan

$report = Get-PrinterDriver -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name        = $_.Name
        Manufacturer = $_.ManufacturerName
        DriverVersion = $_.MajorVersion
        Architecture = $_.PrinterEnvironment
    }
}

if ($report.Count -eq 0) {
    Write-Host "No print drivers found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) print driver record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
