<#
.SYNOPSIS
Reports on IIS virtual directories.

.DESCRIPTION
This script inventories IIS virtual directories for web application documentation.

.EXAMPLE
.\Get-IISVirtualDirectoryReport.ps1

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

Write-Host "Retrieving IIS virtual directories..." -ForegroundColor Cyan

$report = Get-WebVirtualDirectory -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        SiteName    = $_.ItemXPath -replace '^.*/site\[@name=''(.*?)''\].*$', '$1'
        Path        = $_.Path
        PhysicalPath = $_.PhysicalPath
        ApplicationPool = $_.ApplicationPool
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS virtual directories found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS virtual directory record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
