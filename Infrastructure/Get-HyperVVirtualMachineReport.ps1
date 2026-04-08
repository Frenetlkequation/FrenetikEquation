<#
.SYNOPSIS
Reports on Hyper-V virtual machines.

.DESCRIPTION
This script inventories virtual machines on a Hyper-V host for operational and capacity review.

.EXAMPLE
.\Get-HyperVVirtualMachineReport.ps1

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

Write-Host "Retrieving Hyper-V virtual machines..." -ForegroundColor Cyan

$report = Get-VM -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        VMName      = $_.Name
        State       = $_.State
        Generation  = $_.Generation
        CPUUsage    = $_.CPUUsage
        MemoryAssignedGB = [math]::Round($_.MemoryAssigned / 1GB, 2)
        Uptime      = $_.Uptime
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Hyper-V virtual machines found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) virtual machine record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
