<#
.SYNOPSIS
Reports on SharePoint Online OneDrive sync settings.

.DESCRIPTION
This script reviews tenant-level settings that affect OneDrive sync behavior.

.EXAMPLE
.\Get-SharePointOneDriveSyncReport.ps1

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

Write-Host "Retrieving tenant settings..." -ForegroundColor Cyan
$tenant = Get-SPOTenant

$report = [PSCustomObject]@{
    OneDriveStorageQuota     = $tenant.OneDriveStorageQuota
    OneDriveStorageQuotaWarningLevel = $tenant.OneDriveStorageQuotaWarningLevel
    DisableCustomAppAuthentication = $tenant.DisableCustomAppAuthentication
    AllowDownloadingNonWebViewableFiles = $tenant.AllowDownloadingNonWebViewableFiles
}

Write-Host "Retrieved OneDrive sync-related settings." -ForegroundColor Green
$report | Format-Table -AutoSize
