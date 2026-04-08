<#
.SYNOPSIS
Reports on Hyper-V host networking.

.DESCRIPTION
This script inventories Hyper-V host virtual networking configuration and physical uplinks.

.EXAMPLE
.\Get-HyperVHostNetworkReport.ps1

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

Write-Host "Retrieving Hyper-V host network details..." -ForegroundColor Cyan

$report = Get-VMHost -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        ComputerName = $_.ComputerName
        VirtualHardDiskPath = $_.VirtualHardDiskPath
        VirtualMachinePath  = $_.VirtualMachinePath
        MaximumStorageMigrations = $_.MaximumStorageMigrations
        MacAddressMinimum   = $_.MacAddressMinimum
        MacAddressMaximum   = $_.MacAddressMaximum
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Hyper-V host network data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved Hyper-V host network data." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
