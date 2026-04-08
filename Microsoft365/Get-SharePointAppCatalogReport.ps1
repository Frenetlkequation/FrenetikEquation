<#
.SYNOPSIS
Reports on SharePoint Online app catalog settings.

.DESCRIPTION
This script inventories app catalog related tenant settings.

.EXAMPLE
.\Get-SharePointAppCatalogReport.ps1

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
    TenantAppCatalogUrl = $tenant.TenantAppCatalogUrl
    AppCatalogEnabled   = [bool]$tenant.TenantAppCatalogUrl
    DisableCustomAppAuthentication = $tenant.DisableCustomAppAuthentication
}

Write-Host "Retrieved SharePoint app catalog settings." -ForegroundColor Green
$report | Format-Table -AutoSize
