<#
.SYNOPSIS
Reports on SharePoint Online user activity timing.

.DESCRIPTION
This script summarizes site modification timing as a user activity indicator.

.EXAMPLE
.\Get-SharePointUserActivityReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Online.SharePoint.PowerShell

Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
$adminUrl = $env:SPOTenantAdminUrl
if (-not $adminUrl) { throw "Set the SPOTenantAdminUrl environment variable to your SharePoint admin URL." }
Connect-SPOService -Url $adminUrl

Write-Host "Retrieving sites..." -ForegroundColor Cyan
$sites = Get-SPOSite -Limit All

$report = foreach ($site in $sites) {
    [PSCustomObject]@{
        Url            = $site.Url
        Owner          = $site.Owner
        LastActivity   = $site.LastContentModifiedDate
        StorageGB      = [math]::Round($site.StorageUsageCurrent / 1024, 2)
    }
}

Write-Host "Retrieved $($report.Count) site activity record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
