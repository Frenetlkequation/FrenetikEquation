<#
.SYNOPSIS
Reports on Azure virtual machine status and sizing.

.DESCRIPTION
This script retrieves Azure virtual machine information including power state,
size, OS, and location for inventory and operational management.

.EXAMPLE
.\Get-AzureVMStatusReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module Az.Accounts
#Requires -Module Az.Compute

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $vms = Get-AzVM -Status

    foreach ($vm in $vms) {
        [PSCustomObject]@{
            SubscriptionName = $sub.Name
            ResourceGroup    = $vm.ResourceGroupName
            VMName           = $vm.Name
            Location         = $vm.Location
            VMSize           = $vm.HardwareProfile.VmSize
            OSType           = $vm.StorageProfile.OsDisk.OsType
            PowerState       = ($vm.Statuses | Where-Object { $_.Code -like "PowerState/*" }).DisplayStatus
            ProvisionState   = $vm.ProvisioningState
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No virtual machines found." -ForegroundColor Yellow
}
else {
    $running = ($report | Where-Object { $_.PowerState -eq "VM running" }).Count
    $deallocated = ($report | Where-Object { $_.PowerState -eq "VM deallocated" }).Count

    Write-Host "Retrieved $($report.Count) VM(s). Running: $running, Deallocated: $deallocated" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
