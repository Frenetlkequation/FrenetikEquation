<#
.SYNOPSIS
Reports on Exchange Online calendar processing settings.

.DESCRIPTION
This script reviews resource mailbox calendar processing settings for scheduling governance.

.EXAMPLE
.\Get-ExchangeCalendarProcessingReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving resource mailboxes..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails RoomMailbox, EquipmentMailbox

$report = foreach ($mailbox in $mailboxes) {
    $calendar = Get-CalendarProcessing -Identity $mailbox.UserPrincipalName -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        DisplayName             = $mailbox.DisplayName
        PrimarySmtpAddress      = $mailbox.PrimarySmtpAddress
        AutomateProcessing      = $calendar.AutomateProcessing
        BookingWindowInDays     = $calendar.BookingWindowInDays
        AllBookInPolicy         = $calendar.AllBookInPolicy
        AllRequestInPolicy      = $calendar.AllRequestInPolicy
    }
}

if ($report.Count -eq 0) {
    Write-Host "No calendar processing settings found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) calendar processing record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
