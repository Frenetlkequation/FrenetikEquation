<#
.SYNOPSIS
Reports on SNMP configuration.

.DESCRIPTION
This script inventories SNMP service and configuration settings on Windows hosts.

.EXAMPLE
.\Get-SNMPConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving SNMP configuration..." -ForegroundColor Cyan

$feature = Get-WindowsFeature -Name SNMP-Service -ErrorAction SilentlyContinue
$service = Get-Service -Name SNMP -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    FeatureInstalled = if ($feature) { $feature.Installed } else { $false }
    ServiceState     = if ($service) { $service.Status } else { 'NotFound' }
    ServiceStartType = if ($service) { $service.StartType } else { 'Unknown' }
}

Write-Host "SNMP configuration retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
