<#
.SYNOPSIS
Reports on Offline Files configuration.

.DESCRIPTION
This script inventories Offline Files client settings for endpoint review.

.EXAMPLE
.\Get-OfflineFilesConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving Offline Files configuration..." -ForegroundColor Cyan

$policy = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetCache' -ErrorAction SilentlyContinue
$service = Get-Service -Name CscService -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    GroupPolicyEnabled = if ($policy) { $policy.Enabled } else { "Unknown" }
    ServiceState       = if ($service) { $service.Status } else { "NotFound" }
    ServiceStartType   = if ($service) { $service.StartType } else { "Unknown" }
}

Write-Host "Offline Files configuration retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
