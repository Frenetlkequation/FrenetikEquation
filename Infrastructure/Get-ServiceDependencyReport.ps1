<#
.SYNOPSIS
Reports on Windows service dependencies.

.DESCRIPTION
This script inventories service dependency relationships for operational troubleshooting.

.EXAMPLE
.\Get-ServiceDependencyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving service dependencies..." -ForegroundColor Cyan

$report = Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name         = $_.Name
        DisplayName   = $_.DisplayName
        StartName     = $_.StartName
        Dependencies  = if ($_.Dependencies) { $_.Dependencies -join ', ' } else { 'None' }
    }
}

Write-Host "Retrieved service dependency information." -ForegroundColor Green
$report | Format-Table -AutoSize
