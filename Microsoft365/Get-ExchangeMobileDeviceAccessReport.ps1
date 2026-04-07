<#
.SYNOPSIS
Reports on Exchange Online mobile device access configuration.

.DESCRIPTION
This script summarizes ActiveSync mobile device mailbox policies and access
rules in Exchange Online for security and endpoint management review.

.EXAMPLE
.\Get-ExchangeMobileDeviceAccessReport.ps1

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

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mobile device access configuration..." -ForegroundColor Cyan

try {
    $policies = Get-MobileDeviceMailboxPolicy
    $rules = Get-ActiveSyncDeviceAccessRule
}
catch {
    Write-Warning "Failed to retrieve mobile device access data: $_"
    $policies = @()
    $rules = @()
}

$policyReport = $policies | ForEach-Object {
    [PSCustomObject]@{
        RecordType                  = "Policy"
        Name                        = $_.Name
        AllowNonProvisionableDevices = $_.AllowNonProvisionableDevices
        DevicePasswordEnabled       = $_.DevicePasswordEnabled
        MinDevicePasswordLength     = $_.MinDevicePasswordLength
        MaxInactivityTimeDeviceLock = $_.MaxInactivityTimeDeviceLock
    }
}

$ruleReport = $rules | ForEach-Object {
    [PSCustomObject]@{
        RecordType    = "Rule"
        Name          = $_.Name
        Characteristic = $_.Characteristic
        QueryString   = $_.QueryString
        AccessLevel   = $_.AccessLevel
        Priority      = $_.Priority
    }
}

$report = @($policyReport + $ruleReport)

if ($report.Count -eq 0) {
    Write-Host "No mobile device access settings found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) mobile device access record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
