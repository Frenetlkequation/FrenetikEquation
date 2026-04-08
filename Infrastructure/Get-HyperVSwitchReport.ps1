<#
.SYNOPSIS
Reports on Hyper-V virtual switches.

.DESCRIPTION
This script inventories virtual switches and switch types on a Hyper-V host.

.EXAMPLE
.\Get-HyperVSwitchReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module Hyper-V

Write-Host "Retrieving Hyper-V switches..." -ForegroundColor Cyan

$report = Get-VMSwitch -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name         = $_.Name
        SwitchType   = $_.SwitchType
        Notes        = $_.Notes
        NetAdapterInterfaceDescription = $_.NetAdapterInterfaceDescription
        AllowManagementOS = $_.AllowManagementOS
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Hyper-V switches found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) Hyper-V switch record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
