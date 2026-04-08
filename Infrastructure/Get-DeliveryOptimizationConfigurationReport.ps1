<#
.SYNOPSIS
Reports on Delivery Optimization configuration.

.DESCRIPTION
This script inventories Delivery Optimization policy and local configuration settings.

.EXAMPLE
.\Get-DeliveryOptimizationConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving Delivery Optimization configuration..." -ForegroundColor Cyan

$policy = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -ErrorAction SilentlyContinue
$status = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization' -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    DownloadMode = if ($policy) { $policy.DODownloadMode } else { "Default" }
    DOMaxCacheAge = if ($policy) { $policy.DOMaxCacheAge } else { "Unknown" }
    CacheSize     = if ($status) { $status.CacheSize } else { "Unknown" }
    Mode          = if ($status) { $status.DownloadMode } else { "Unknown" }
}

Write-Host "Delivery Optimization configuration retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
