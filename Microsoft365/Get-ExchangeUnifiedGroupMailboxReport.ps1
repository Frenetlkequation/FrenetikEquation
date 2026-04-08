<#
.SYNOPSIS
Reports on Exchange Online Microsoft 365 group mailboxes.

.DESCRIPTION
This script inventories unified group mailboxes for collaboration governance.

.EXAMPLE
.\Get-ExchangeUnifiedGroupMailboxReport.ps1

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
        DisplayName         = $group.DisplayName
        PrimarySmtpAddress  = $group.PrimarySmtpAddress
        AccessType          = $group.AccessType
        SubscriptionEnabled = $group.SubscriptionEnabled
        AlwaysSubscribeMembersToCalendarEvents = $group.AlwaysSubscribeMembersToCalendarEvents
    }
}

if ($report.Count -eq 0) {
    Write-Host "No unified groups found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) unified group record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
