<#
.SYNOPSIS
Reports on Active Directory forest site links.

.DESCRIPTION
This script lists site links configured in the forest.

.EXAMPLE
.\Get-ADForestSiteLinkReport.ps1

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

Write-Host "Retrieving forest site link information..." -ForegroundColor Cyan

$links = Get-ADReplicationSiteLink -Filter *
$report = foreach ($link in $links) {
    [PSCustomObject]@{
        LinkName = $link.Name
        Cost = $link.Cost
        ReplicationFrequencyInMinutes = $link.ReplicationFrequencyInMinutes
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
