<#
.SYNOPSIS
Reports on IIS websites.

.DESCRIPTION
This script inventories IIS websites and their operational state.

.EXAMPLE
.\Get-IISSiteReport.ps1

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

Write-Host "Retrieving IIS sites..." -ForegroundColor Cyan

$report = Get-Website -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name      = $_.Name
        State     = $_.State
        PhysicalPath = $_.PhysicalPath
        ID        = $_.ID
        Bindings  = $_.Bindings.Collection.Count
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS sites found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS site record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
