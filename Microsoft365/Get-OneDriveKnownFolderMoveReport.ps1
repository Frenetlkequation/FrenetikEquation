<#
.SYNOPSIS
Reports on OneDrive known folder move readiness.

.DESCRIPTION
This script reviews tenant settings that support OneDrive known folder move.

.EXAMPLE
.\Get-OneDriveKnownFolderMoveReport.ps1

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
    OneDriveFilesOnDemandEnabled = $tenant.OneDriveFilesOnDemandEnabled
    SyncAdminReportsEnabled      = $tenant.SyncAdminReportsEnabled
    NotifyOwnersWhenInvited      = $tenant.NotifyOwnersWhenInvited
}

Write-Host "Retrieved OneDrive known folder move settings." -ForegroundColor Green
$report | Format-Table -AutoSize
