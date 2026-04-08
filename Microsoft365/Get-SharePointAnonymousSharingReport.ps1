<#
.SYNOPSIS
Reports on SharePoint Online anonymous sharing configuration.

.DESCRIPTION
This script inventories sites that allow anonymous sharing links.

.EXAMPLE
.\Get-SharePointAnonymousSharingReport.ps1

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

$report = foreach ($site in $sites | Where-Object { $_.SharingCapability -ne "Disabled" }) {
    [PSCustomObject]@{
        Url               = $site.Url
        Owner             = $site.Owner
        SharingCapability  = $site.SharingCapability
        LockState          = $site.LockState
    }
}

Write-Host "Retrieved $($report.Count) sharing-enabled site record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
