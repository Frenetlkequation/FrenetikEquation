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

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied,
    including but not limited to the warranties of merchantability, fitness for a
    particular purpose, and noninfringement.

    In no event shall the authors, contributors, or copyright holders (FrenetikEquation)
    be liable for any claim, damages, or other liability, whether in an action of
    contract, tort, or otherwise, arising from, out of, or in connection with this
    script or the use or other dealings in this script. This includes, without
    limitation, any direct, indirect, incidental, special, exemplary, or consequential
    damages, including but not limited to loss of data, loss of revenue, business
    interruption, or damage to systems.

    USE AT YOUR OWN RISK. You are solely responsible for testing this script in a
    non-production environment before deploying to any production system. The user
    assumes all responsibility and risk for the use of this script. It is strongly
    recommended that you review, understand, and validate the script logic before
    execution.

    By using this script, you acknowledge and agree to these terms. If you do not
    agree, do not use this script. Refer to the LICENSE file in the root of this
    repository for the full license terms.
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
