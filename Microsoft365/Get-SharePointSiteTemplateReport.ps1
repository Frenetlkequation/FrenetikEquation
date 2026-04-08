<#
.SYNOPSIS
Reports on SharePoint Online site templates.

.DESCRIPTION
This script inventories site templates across the tenant.

.EXAMPLE
.\Get-SharePointSiteTemplateReport.ps1

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
        Url      = $site.Url
        Owner    = $site.Owner
        Template = $site.Template
    }
}

Write-Host "Retrieved $($report.Count) site template record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
