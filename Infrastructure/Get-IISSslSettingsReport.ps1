<#
.SYNOPSIS
Reports on IIS SSL settings.

.DESCRIPTION
This script inventories HTTPS bindings and SSL-related settings for IIS sites.

.EXAMPLE
.\Get-IISSslSettingsReport.ps1

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

Write-Host "Retrieving IIS SSL settings..." -ForegroundColor Cyan

$report = Get-Website -ErrorAction SilentlyContinue | ForEach-Object {
    $bindings = Get-WebBinding -Name $_.Name -Protocol https -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        SiteName      = $_.Name
        HttpsBindingCount = @($bindings).Count
        SslFlags      = if ($bindings) { ($bindings | Select-Object -First 1).sslFlags } else { "None" }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS SSL settings found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS SSL record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
