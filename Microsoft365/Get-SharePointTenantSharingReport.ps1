<#
.SYNOPSIS
Reports on SharePoint Online tenant sharing settings.

.DESCRIPTION
This script inventories tenant sharing configuration for governance review.

.EXAMPLE
.\Get-SharePointTenantSharingReport.ps1

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
    SharingCapability = $tenant.SharingCapability
    DefaultSharingLinkType = $tenant.DefaultSharingLinkType
    ShowEveryoneClaim = $tenant.ShowEveryoneClaim
    RequireAcceptingAccountMatchInvitedAccount = $tenant.RequireAcceptingAccountMatchInvitedAccount
}

Write-Host "Retrieved SharePoint tenant sharing settings." -ForegroundColor Green
$report | Format-Table -AutoSize
