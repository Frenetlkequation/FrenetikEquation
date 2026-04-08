<#
.SYNOPSIS
Reports on SharePoint Online site sharing settings.

.DESCRIPTION
This script inventories site sharing capability and lock state.

.EXAMPLE
.\Get-SharePointSiteSharingReport.ps1

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

Write-Host "Retrieving sites..." -ForegroundColor Cyan
$sites = Get-SPOSite -Limit All

$report = foreach ($site in $sites) {
    [PSCustomObject]@{
        Url               = $site.Url
        Owner             = $site.Owner
        SharingCapability  = $site.SharingCapability
        LockState         = $site.LockState
    }
}

Write-Host "Retrieved $($report.Count) site sharing record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
