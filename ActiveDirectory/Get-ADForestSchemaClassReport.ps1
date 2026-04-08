<#
.SYNOPSIS
Reports on Active Directory forest schema classes.

.DESCRIPTION
This script counts schema class objects in the forest schema partition.

.EXAMPLE
.\Get-ADForestSchemaClassReport.ps1

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

Write-Host "Retrieving forest schema class information..." -ForegroundColor Cyan

$rootDse = Get-ADRootDSE
$classes = Get-ADObject -SearchBase $rootDse.SchemaNamingContext -LDAPFilter '(objectClass=classSchema)'
$report = @([PSCustomObject]@{
    SchemaNamingContext = $rootDse.SchemaNamingContext
    ClassCount = @($classes).Count
})

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
