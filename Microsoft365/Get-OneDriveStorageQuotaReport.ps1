<#
.SYNOPSIS
Reports on OneDrive storage quotas.

.DESCRIPTION
This script inventories personal site storage usage and quotas.

.EXAMPLE
.\Get-OneDriveStorageQuotaReport.ps1

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
        Url          = $site.Url
        Owner        = $site.Owner
        StorageGB    = [math]::Round($site.StorageUsageCurrent / 1024, 2)
        QuotaGB      = [math]::Round($site.StorageQuota / 1024, 2)
        UsagePercent = if ($site.StorageQuota -gt 0) { [math]::Round(($site.StorageUsageCurrent / $site.StorageQuota) * 100, 1) } else { 0 }
    }
}

Write-Host "Retrieved $($report.Count) OneDrive quota record(s)." -ForegroundColor Green
$report | Sort-Object StorageGB -Descending | Format-Table -AutoSize
