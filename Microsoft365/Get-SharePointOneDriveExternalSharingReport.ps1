<#
.SYNOPSIS
Reports on SharePoint Online OneDrive external sharing.

.DESCRIPTION
This script inventories OneDrive sharing settings for external collaboration review.

.EXAMPLE
.\Get-SharePointOneDriveExternalSharingReport.ps1

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

Write-Host "Retrieving OneDrive sites..." -ForegroundColor Cyan
$sites = Get-SPOSite -IncludePersonalSite $true -Limit All

$report = foreach ($site in $sites | Where-Object { $_.Url -like "*-my.sharepoint.com/personal/*" }) {
    [PSCustomObject]@{
        Url              = $site.Url
        Owner            = $site.Owner
        SharingCapability = $site.SharingCapability
        AnonymousLinks   = $site.SharingCapability -ne "Disabled"
    }
}

Write-Host "Retrieved $($report.Count) OneDrive sharing record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
