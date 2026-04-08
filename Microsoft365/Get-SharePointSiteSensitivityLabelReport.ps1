<#
.SYNOPSIS
Reports on SharePoint Online site sensitivity labels.

.DESCRIPTION
This script inventories sensitivity labels assigned to sites.

.EXAMPLE
.\Get-SharePointSiteSensitivityLabelReport.ps1

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
        Url             = $site.Url
        Owner           = $site.Owner
        SensitivityLabel = $site.SensitivityLabel
        Template        = $site.Template
    }
}

Write-Host "Retrieved $($report.Count) site sensitivity record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
