<#
.SYNOPSIS
Reports on Remote Desktop Services licensing configuration.

.DESCRIPTION
This script inventories RDS licensing settings for remote desktop deployments.

.EXAMPLE
.\Get-RemoteDesktopLicenseConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving Remote Desktop licensing configuration..." -ForegroundColor Cyan

$report = [PSCustomObject]@{
    LicenseServers = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core' -ErrorAction SilentlyContinue).LicensingServerName
    LicensingMode  = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core' -ErrorAction SilentlyContinue).LicensingMode
    GracePeriodDays = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod' -ErrorAction SilentlyContinue).DaysRemaining
}

Write-Host "Remote Desktop licensing configuration retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
