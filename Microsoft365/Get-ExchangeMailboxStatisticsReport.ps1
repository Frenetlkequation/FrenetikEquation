<#
.SYNOPSIS
Reports on Exchange Online mailbox statistics.

.DESCRIPTION
This script summarizes mailbox size and item counts for reporting.

.EXAMPLE
.\Get-ExchangeMailboxStatisticsReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox statistics..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox, RoomMailbox, EquipmentMailbox

$report = foreach ($mailbox in $mailboxes) {
    $stats = Get-EXOMailboxStatistics -Identity $mailbox.UserPrincipalName -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        DisplayName       = $mailbox.DisplayName
        UserPrincipalName = $mailbox.UserPrincipalName
        MailboxType       = $mailbox.RecipientTypeDetails
        ItemCount         = $stats.ItemCount
        TotalItemSize     = $stats.TotalItemSize
        LastLogonTime     = $stats.LastLogonTime
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mailbox statistics found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) mailbox statistics record(s)." -ForegroundColor Green
    $report | Sort-Object TotalItemSize -Descending | Format-Table -AutoSize
}
