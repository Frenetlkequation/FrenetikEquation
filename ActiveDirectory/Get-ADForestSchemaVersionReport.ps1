<#
.SYNOPSIS
Reports on Active Directory forest schema version.

.DESCRIPTION
This script reads the schema objectVersion from the forest schema partition.

.EXAMPLE
.\Get-ADForestSchemaVersionReport.ps1

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

Write-Host "Retrieving forest schema version information..." -ForegroundColor Cyan

$rootDse = Get-ADRootDSE
$schema = Get-ADObject -Identity $rootDse.SchemaNamingContext -Properties objectVersion
$report = @([PSCustomObject]@{
    SchemaNamingContext = $schema.DistinguishedName
    SchemaVersion = $schema.ObjectVersion
})

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
