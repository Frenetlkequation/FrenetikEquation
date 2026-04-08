<#
.SYNOPSIS
Reports on WSUS client configuration.

.DESCRIPTION
This script inventories Windows Update policy settings for WSUS-managed clients.

.EXAMPLE
.\Get-WSUSClientConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving WSUS client configuration..." -ForegroundColor Cyan

$policy = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -ErrorAction SilentlyContinue
$au = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    WUServer           = if ($policy) { $policy.WUServer } else { 'Unknown' }
    WUStatusServer     = if ($policy) { $policy.WUStatusServer } else { 'Unknown' }
    AUOptions          = if ($au) { $au.AUOptions } else { 'Unknown' }
    UseWUServer        = if ($au) { $au.UseWUServer } else { 'Unknown' }
}

Write-Host "WSUS client configuration retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
