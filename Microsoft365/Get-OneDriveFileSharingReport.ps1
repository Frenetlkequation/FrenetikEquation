<#
.SYNOPSIS
Reports on OneDrive file sharing settings.

.DESCRIPTION
This script inventories OneDrive sharing-capable personal sites.

.EXAMPLE
.\Get-OneDriveFileSharingReport.ps1

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

$report = foreach ($site in $sites | Where-Object { $_.Url -like "*-my.sharepoint.com/personal/*" -and $_.SharingCapability -ne "Disabled" }) {
    [PSCustomObject]@{
        Url              = $site.Url
        Owner            = $site.Owner
        SharingCapability = $site.SharingCapability
    }
}

Write-Host "Retrieved $($report.Count) OneDrive file sharing record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
