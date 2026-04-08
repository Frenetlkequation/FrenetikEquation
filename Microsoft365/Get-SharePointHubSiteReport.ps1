<#
.SYNOPSIS
Reports on SharePoint Online hub sites.

.DESCRIPTION
This script inventories hub sites and their key properties.

.EXAMPLE
.\Get-SharePointHubSiteReport.ps1

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

Write-Host "Retrieving hub sites..." -ForegroundColor Cyan
$hubs = Get-SPOHubSite

$report = foreach ($hub in $hubs) {
    [PSCustomObject]@{
        Id          = $hub.ID
        Title       = $hub.Title
        Url         = $hub.SiteUrl
        Description = $hub.Description
    }
}

Write-Host "Retrieved $($report.Count) hub site record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
