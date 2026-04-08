<#
.SYNOPSIS
Reports on Active Directory forest summary information.

.DESCRIPTION
This script summarizes the forest name, root domain, and forest mode.

.EXAMPLE
.\Get-ADForestSummaryReport.ps1

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

Write-Host "Retrieving forest summary information..." -ForegroundColor Cyan

$forest = Get-ADForest
$report = @([PSCustomObject]@{
    ReportName = 'Forest Summary'
    ForestName = $forest.Name
    RootDomain = $forest.RootDomain
    ForestMode = $forest.ForestMode
})

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
