<#
.SYNOPSIS
Reports on Microsoft 365 unified group membership.

.DESCRIPTION
This script inventories unified groups and their member counts.

.EXAMPLE
.\Get-M365UnifiedGroupMembershipSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving unified groups..." -ForegroundColor Cyan
$groups = Get-UnifiedGroup -ResultSize Unlimited

$report = foreach ($group in $groups) {
    [PSCustomObject]@{
        DisplayName        = $group.DisplayName
        PrimarySmtpAddress = $group.PrimarySmtpAddress
        AccessType         = $group.AccessType
        SubscriptionEnabled = $group.SubscriptionEnabled
    }
}

Write-Host "Retrieved $($report.Count) unified group record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
