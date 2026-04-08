<#
.SYNOPSIS
Reports on IIS request filtering.

.DESCRIPTION
This script inventories IIS request filtering settings for websites and applications.

.EXAMPLE
.\Get-IISRequestFilteringReport.ps1

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

Write-Host "Retrieving IIS request filtering settings..." -ForegroundColor Cyan

$report = Get-Website -ErrorAction SilentlyContinue | ForEach-Object {
    $filter = Get-WebConfiguration -Filter "system.webServer/security/requestFiltering" -PSPath "IIS:\Sites\$($_.Name)" -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        SiteName         = $_.Name
        AllowDoubleEscaping = $filter.allowDoubleEscaping
        AllowHighBitCharacters = $filter.allowHighBitCharacters
        RemoveServerHeader = $filter.removeServerHeader
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS request filtering data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS request filtering record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
