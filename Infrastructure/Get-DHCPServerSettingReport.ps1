<#
.SYNOPSIS
Reports on DHCP server settings.

.DESCRIPTION
This script inventories DHCP server level settings for operational review and configuration auditing.

.EXAMPLE
.\Get-DHCPServerSettingReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module DhcpServer

Write-Host "Retrieving DHCP server settings..." -ForegroundColor Cyan

$setting = Get-DhcpServerSetting -ErrorAction SilentlyContinue

$report = if ($setting) {
    [PSCustomObject]@{
        IsAuthorized   = $setting.IsAuthorized
        ConflictDetectionAttempts = $setting.ConflictDetectionAttempts
        BindState      = $setting.BindState
        ComputerName   = $setting.ComputerName
    }
} else {
    @()
}

if ($report.Count -eq 0) {
    Write-Host "No DHCP server settings found." -ForegroundColor Yellow
}
else {
    Write-Host "DHCP server settings retrieved." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
