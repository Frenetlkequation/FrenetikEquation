<#
.SYNOPSIS
Reports on Active Directory forest sites.

.DESCRIPTION
This script lists all sites defined in the forest.

.EXAMPLE
.\Get-ADForestSiteReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    USE AT YOUR OWN RISK.
#>

[CmdletBinding()]
param ()

#Requires -Module ActiveDirectory

Write-Host "Retrieving forest site information..." -ForegroundColor Cyan

$sites = Get-ADReplicationSite -Filter *
$report = foreach ($site in $sites) {
    [PSCustomObject]@{
        SiteName = $site.Name
        DistinguishedName = $site.DistinguishedName
        Description = $site.Description
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
