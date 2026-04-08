<#
.SYNOPSIS
Reports on Active Directory forest UPN suffixes.

.DESCRIPTION
This script lists UPN suffixes configured in the forest.

.EXAMPLE
.\Get-ADForestUPNSuffixReport.ps1

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

Write-Host "Retrieving forest UPN suffix information..." -ForegroundColor Cyan

$forest = Get-ADForest
$report = foreach ($suffix in $forest.UPNSuffixes) {
    [PSCustomObject]@{
        ForestName = $forest.Name
        UPNuffix = $suffix
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
