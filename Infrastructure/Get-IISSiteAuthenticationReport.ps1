<#
.SYNOPSIS
Reports on IIS site authentication settings.

.DESCRIPTION
This script inventories authentication settings for IIS sites to support security review.

.EXAMPLE
.\Get-IISSiteAuthenticationReport.ps1

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

Write-Host "Retrieving IIS site authentication settings..." -ForegroundColor Cyan

$report = Get-Website -ErrorAction SilentlyContinue | ForEach-Object {
    $siteName = $_.Name
    $auth = Get-WebConfiguration -Filter "system.webServer/security/authentication" -PSPath "IIS:\Sites\$siteName" -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        SiteName        = $siteName
        Anonymous       = $auth.anonymousAuthentication.enabled
        Basic           = $auth.basicAuthentication.enabled
        Windows         = $auth.windowsAuthentication.enabled
        Digest          = $auth.digestAuthentication.enabled
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS authentication data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS authentication record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
