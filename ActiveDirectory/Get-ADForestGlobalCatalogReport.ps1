<#
.SYNOPSIS
Reports on Active Directory forest global catalog servers.

.DESCRIPTION
This script inventories global catalog servers in the forest.

.EXAMPLE
.\Get-ADForestGlobalCatalogReport.ps1

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

Write-Host "Retrieving global catalog information..." -ForegroundColor Cyan

$forest = Get-ADForest
$report = foreach ($site in $forest.Sites) {
    [PSCustomObject]@{
        ReportName = 'Global Catalog'
        ForestName = $forest.Name
        SiteName   = $site
        CatalogCount = @($forest.GlobalCatalogs).Count
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
