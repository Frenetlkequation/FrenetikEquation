<#
.SYNOPSIS
Reports on Active Directory forest subnets.

.DESCRIPTION
This script lists all subnets defined in the forest.

.EXAMPLE
.\Get-ADForestSubnetReport.ps1

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

Write-Host "Retrieving forest subnet information..." -ForegroundColor Cyan

$subnets = Get-ADReplicationSubnet -Filter *
$report = foreach ($subnet in $subnets) {
    [PSCustomObject]@{
        SubnetName = $subnet.Name
        Site = $subnet.Site
        DistinguishedName = $subnet.DistinguishedName
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
