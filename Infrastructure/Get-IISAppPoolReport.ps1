<#
.SYNOPSIS
Reports on IIS application pools.

.DESCRIPTION
This script inventories IIS application pools and their runtime state.

.EXAMPLE
.\Get-IISAppPoolReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Modules WebAdministration

Import-Module WebAdministration -ErrorAction SilentlyContinue

Write-Host "Retrieving IIS application pools..." -ForegroundColor Cyan

$report = Get-ChildItem IIS:\AppPools -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name      = $_.Name
        State     = $_.State
        ManagedRuntimeVersion = $_.managedRuntimeVersion
        StartMode = $_.startMode
        AutoStart = $_.autoStart
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS application pools found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS application pool record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
