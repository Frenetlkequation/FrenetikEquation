<#
.SYNOPSIS
Reports on Hyper-V host summary information.

.DESCRIPTION
This script inventories a Hyper-V host summary including CPU, memory, and version details.

.EXAMPLE
.\Get-HyperVHostSummaryReport.ps1

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

Write-Host "Retrieving Hyper-V host summary..." -ForegroundColor Cyan

$hostInfo = Get-VMHost -ErrorAction SilentlyContinue
$report = if ($hostInfo) {
    [PSCustomObject]@{
        ComputerName = $hostInfo.ComputerName
        LogicalProcessorCount = $hostInfo.LogicalProcessorCount
        MemoryCapacityGB = [math]::Round($hostInfo.MemoryCapacity / 1GB, 2)
        VirtualMachineMigrationEnabled = $hostInfo.VirtualMachineMigrationEnabled
        Version = $hostInfo.Version
    }
} else {
    @()
}

if ($report.Count -eq 0) {
    Write-Host "No Hyper-V host summary data found." -ForegroundColor Yellow
}
else {
    Write-Host "Hyper-V host summary retrieved." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
