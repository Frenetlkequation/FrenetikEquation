<#
.SYNOPSIS
Reports on Active Directory forest FSMO roles.

.DESCRIPTION
This script lists the forest-level FSMO role holders.

.EXAMPLE
.\Get-ADForestFSMORoleReport.ps1

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

Write-Host "Retrieving forest FSMO role information..." -ForegroundColor Cyan

$forest = Get-ADForest
$report = @([PSCustomObject]@{
    ReportName = 'Forest FSMO Roles'
    SchemaMaster = $forest.SchemaMaster
    DomainNamingMaster = $forest.DomainNamingMaster
})

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
