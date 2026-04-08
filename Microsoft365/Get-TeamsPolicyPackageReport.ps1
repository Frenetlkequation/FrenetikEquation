<#
.SYNOPSIS
Reports on Microsoft Teams policy packages.

.DESCRIPTION
This script inventories Teams policy packages for governance review.

.EXAMPLE
.\Get-TeamsPolicyPackageReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving policy packages..." -ForegroundColor Cyan
$packages = Get-CsTeamsPolicyPackage

$report = foreach ($package in $packages) {
    [PSCustomObject]@{
        Identity     = $package.Identity
        DisplayName  = $package.DisplayName
        PackageType  = $package.PackageType
    }
}

Write-Host "Retrieved $($report.Count) policy package record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
