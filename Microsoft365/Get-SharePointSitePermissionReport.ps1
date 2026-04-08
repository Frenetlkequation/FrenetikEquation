<#
.SYNOPSIS
Reports on SharePoint Online site permissions.

.DESCRIPTION
This script inventories users with direct site permissions.

.EXAMPLE
.\Get-SharePointSitePermissionReport.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Finance"

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]$SiteUrl
)

#Requires -Module Microsoft.Online.SharePoint.PowerShell

Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
$adminUrl = $env:SPOTenantAdminUrl
if (-not $adminUrl) { throw "Set the SPOTenantAdminUrl environment variable to your SharePoint admin URL." }
Connect-SPOService -Url $adminUrl

if (-not $SiteUrl) {
    $SiteUrl = (Get-SPOSite -Limit All | Select-Object -First 1).Url
}

Write-Host "Retrieving site users for $SiteUrl..." -ForegroundColor Cyan
$users = Get-SPOUser -Site $SiteUrl -ErrorAction SilentlyContinue

$report = foreach ($user in @($users)) {
    [PSCustomObject]@{
        SiteUrl   = $SiteUrl
        LoginName = $user.LoginName
        DisplayName = $user.DisplayName
        IsSiteAdmin = $user.IsSiteAdmin
    }
}

Write-Host "Retrieved $($report.Count) site permission record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
