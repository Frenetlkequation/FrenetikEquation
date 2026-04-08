<#
.SYNOPSIS
Reports on inactive OneDrive accounts.

.DESCRIPTION
This script inventories personal sites with stale modification dates.

.EXAMPLE
.\Get-OneDriveInactiveAccountReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param (
    [Parameter()]
    [int]$Days = 180
)

#Requires -Module Microsoft.Online.SharePoint.PowerShell

Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
$adminUrl = $env:SPOTenantAdminUrl
if (-not $adminUrl) { throw "Set the SPOTenantAdminUrl environment variable to your SharePoint admin URL." }
Connect-SPOService -Url $adminUrl

$cutoff = (Get-Date).AddDays(-$Days)

Write-Host "Retrieving OneDrive sites..." -ForegroundColor Cyan
$sites = Get-SPOSite -IncludePersonalSite $true -Limit All

$report = foreach ($site in $sites | Where-Object { $_.Url -like "*-my.sharepoint.com/personal/*" -and $_.LastContentModifiedDate -lt $cutoff }) {
    [PSCustomObject]@{
        Url          = $site.Url
        Owner        = $site.Owner
        LastModified = $site.LastContentModifiedDate
        StorageGB    = [math]::Round($site.StorageUsageCurrent / 1024, 2)
    }
}

Write-Host "Retrieved $($report.Count) inactive OneDrive record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
