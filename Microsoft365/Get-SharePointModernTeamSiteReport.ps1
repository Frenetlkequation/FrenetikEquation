<#
.SYNOPSIS
Reports on SharePoint Online modern team sites.

.DESCRIPTION
This script inventories modern team sites for governance review.

.EXAMPLE
.\Get-SharePointModernTeamSiteReport.ps1

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

$report = foreach ($site in $sites | Where-Object { $_.Template -like "GROUP*" -or $_.Template -like "STS*" }) {
    [PSCustomObject]@{
        Url         = $site.Url
        Owner       = $site.Owner
        Template    = $site.Template
        StorageGB   = [math]::Round($site.StorageUsageCurrent / 1024, 2)
        LastModified = $site.LastContentModifiedDate
    }
}

Write-Host "Retrieved $($report.Count) modern team site record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
