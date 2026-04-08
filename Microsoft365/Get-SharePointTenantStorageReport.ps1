<#
.SYNOPSIS
Reports on SharePoint Online tenant storage usage.

.DESCRIPTION
This script inventories tenant storage and quota settings.

.EXAMPLE
.\Get-SharePointTenantStorageReport.ps1

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
    StorageQuota         = $tenant.StorageQuota
    StorageQuotaWarning  = $tenant.StorageQuotaWarningLevel
    OneDriveStorageQuota  = $tenant.OneDriveStorageQuota
    OneDriveWarningLevel  = $tenant.OneDriveStorageQuotaWarningLevel
}

Write-Host "Retrieved SharePoint tenant storage settings." -ForegroundColor Green
$report | Format-Table -AutoSize
