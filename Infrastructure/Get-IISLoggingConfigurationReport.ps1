<#
.SYNOPSIS
Reports on IIS logging configuration.

.DESCRIPTION
This script inventories IIS logging settings across websites for operational review.

.EXAMPLE
.\Get-IISLoggingConfigurationReport.ps1

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

Write-Host "Retrieving IIS logging settings..." -ForegroundColor Cyan

$report = Get-Website -ErrorAction SilentlyContinue | ForEach-Object {
    $site = $_
    $log = Get-WebConfigurationProperty -Filter "system.applicationHost/sites/site[@name='$($site.Name)']/logFile" -Name * -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        SiteName      = $site.Name
        State         = $site.State
        LogFormat     = $log.logFormat
        Directory     = $log.directory
        TruncateSize  = $log.truncateSize
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS logging settings found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS logging record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
