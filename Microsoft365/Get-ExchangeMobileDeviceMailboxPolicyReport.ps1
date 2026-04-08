<#
.SYNOPSIS
Reports on Exchange Online mobile device mailbox policies.

.DESCRIPTION
This script inventories mobile device mailbox policies for access governance.

.EXAMPLE
.\Get-ExchangeMobileDeviceMailboxPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mobile device mailbox policies..." -ForegroundColor Cyan
$policies = Get-MobileDeviceMailboxPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Name                      = $policy.Name
        AllowNonProvisionableDevices = $policy.AllowNonProvisionableDevices
        AlphanumericDevicePasswordRequired = $policy.AlphanumericDevicePasswordRequired
        DevicePasswordEnabled     = $policy.DevicePasswordEnabled
        MaxPasswordFailedAttempts = $policy.MaxPasswordFailedAttempts
        PasswordRecoveryEnabled   = $policy.PasswordRecoveryEnabled
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mobile device mailbox policies found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) mobile device policy record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
