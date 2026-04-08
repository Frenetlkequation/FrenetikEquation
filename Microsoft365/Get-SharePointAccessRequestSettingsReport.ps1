<#
.SYNOPSIS
Reports on SharePoint Online access request settings.

.DESCRIPTION
This script inventories tenant site access request related settings.

.EXAMPLE
.\Get-SharePointAccessRequestSettingsReport.ps1

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
    RequestFilesLinkEnabled = $tenant.RequestFilesLinkEnabled
    SharingCapability       = $tenant.SharingCapability
    DisableCustomAppAuthentication = $tenant.DisableCustomAppAuthentication
    CommentsOnSitePagesDisabled = $tenant.CommentsOnSitePagesDisabled
}

Write-Host "Retrieved SharePoint tenant settings." -ForegroundColor Green
$report | Format-Table -AutoSize
