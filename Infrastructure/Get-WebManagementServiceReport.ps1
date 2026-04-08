<#
.SYNOPSIS
Reports on the Web Management Service.

.DESCRIPTION
This script inventories the IIS Web Management Service status for remote administration review.

.EXAMPLE
.\Get-WebManagementServiceReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving Web Management Service status..." -ForegroundColor Cyan

$service = Get-Service -Name WMSVC -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    ServiceState   = if ($service) { $service.Status } else { 'NotFound' }
    StartType      = if ($service) { $service.StartType } else { 'Unknown' }
    DisplayName    = if ($service) { $service.DisplayName } else { 'Unknown' }
}

Write-Host "Web Management Service status retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
