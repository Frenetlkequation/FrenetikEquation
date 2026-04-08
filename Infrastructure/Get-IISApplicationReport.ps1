<#
.SYNOPSIS
Reports on IIS applications.

.DESCRIPTION
This script inventories IIS applications and their parent sites for web server administration.

.EXAMPLE
.\Get-IISApplicationReport.ps1

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

Write-Host "Retrieving IIS applications..." -ForegroundColor Cyan

$report = Get-WebApplication -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Site       = $_.ItemXPath -replace '^.*/site\[@name=''(.*?)''\].*$', '$1'
        Path       = $_.Path
        ApplicationPool = $_.ApplicationPool
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS applications found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS application record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
