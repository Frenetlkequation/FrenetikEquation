<#
.SYNOPSIS
Reports on Active Directory forest optional features.

.DESCRIPTION
This script lists forest optional features and their status.

.EXAMPLE
.\Get-ADForestOptionalFeatureReport.ps1

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

Write-Host "Retrieving forest optional feature information..." -ForegroundColor Cyan

$features = Get-ADOptionalFeature -Filter *
$report = foreach ($feature in $features) {
    [PSCustomObject]@{
        FeatureName = $feature.Name
        FeatureScope = $feature.FeatureScope
        EnabledScopes = @($feature.EnabledScopes).Count
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
