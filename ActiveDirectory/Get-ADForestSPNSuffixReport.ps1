<#
.SYNOPSIS
Reports on Active Directory forest SPN suffixes.

.DESCRIPTION
This script lists SPN suffixes configured in the forest.

.EXAMPLE
.\Get-ADForestSPNSuffixReport.ps1

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

Write-Host "Retrieving forest SPN suffix information..." -ForegroundColor Cyan

$forest = Get-ADForest
$report = foreach ($suffix in $forest.SPNSuffixes) {
    [PSCustomObject]@{
        ForestName = $forest.Name
        SPNSuffix = $suffix
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
