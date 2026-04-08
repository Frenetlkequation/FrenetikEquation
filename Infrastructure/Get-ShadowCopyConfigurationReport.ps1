<#
.SYNOPSIS
Reports on shadow copy configuration.

.DESCRIPTION
This script inventories shadow copy storage settings for volumes on the local computer.

.EXAMPLE
.\Get-ShadowCopyConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving shadow copy configuration..." -ForegroundColor Cyan

$report = Get-CimInstance -ClassName Win32_ShadowStorage -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Volume     = $_.Volume
        DiffArea   = $_.DiffVolume
        MaxSizeGB  = [math]::Round($_.MaxSpace / 1GB, 2)
        UsedSpaceGB = [math]::Round($_.UsedSpace / 1GB, 2)
    }
}

if ($report.Count -eq 0) {
    Write-Host "No shadow copy configuration found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) shadow copy configuration record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
