<#
.SYNOPSIS
Reports on SharePoint Online site group membership.

.DESCRIPTION
This script inventories SharePoint site groups and their members.

.EXAMPLE
.\Get-SharePointSiteGroupMembershipReport.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Finance"

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

Write-Host "Retrieving site groups for $SiteUrl..." -ForegroundColor Cyan
$groups = Get-SPOSiteGroup -Site $SiteUrl -ErrorAction SilentlyContinue

$report = foreach ($group in @($groups)) {
    [PSCustomObject]@{
        SiteUrl    = $SiteUrl
        GroupName  = $group.Title
        Owner      = $group.OwnerTitle
        MemberCount = @($group.Users).Count
    }
}

Write-Host "Retrieved $($report.Count) site group record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
