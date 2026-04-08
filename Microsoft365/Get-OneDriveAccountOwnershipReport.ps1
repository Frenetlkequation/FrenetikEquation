<#
.SYNOPSIS
Reports on OneDrive account ownership.

.DESCRIPTION
This script inventories personal sites and their assigned owners.

.EXAMPLE
.\Get-OneDriveAccountOwnershipReport.ps1

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
        Url   = $site.Url
        Owner = $site.Owner
        StorageGB = [math]::Round($site.StorageUsageCurrent / 1024, 2)
    }
}

Write-Host "Retrieved $($report.Count) OneDrive ownership record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
