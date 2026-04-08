<#
.SYNOPSIS
Reports on Windows service startup modes.

.DESCRIPTION
This script summarizes Windows service startup types for service governance.

.EXAMPLE
.\Get-ServiceStartupSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Summarizing service startup modes..." -ForegroundColor Cyan

$services = Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue
$report = $services | Group-Object StartMode | ForEach-Object {
    [PSCustomObject]@{
        StartMode = if ($_.Name) { $_.Name } else { 'Unknown' }
        Count     = $_.Count
    }
}

Write-Host "Service startup summary retrieved." -ForegroundColor Green
$report | Sort-Object Count -Descending | Format-Table -AutoSize
