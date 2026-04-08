<#
.SYNOPSIS
Reports on Exchange Online user mailboxes.

.DESCRIPTION
This script inventories user mailboxes for mailbox governance and review.

.EXAMPLE
.\Get-ExchangeUserMailboxReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving user mailboxes..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

$report = foreach ($mailbox in $mailboxes) {
    [PSCustomObject]@{
        DisplayName        = $mailbox.DisplayName
        UserPrincipalName  = $mailbox.UserPrincipalName
        PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
        ArchiveStatus      = $mailbox.ArchiveStatus
        LitigationHold     = $mailbox.LitigationHoldEnabled
        RecipientType      = $mailbox.RecipientTypeDetails
    }
}

if ($report.Count -eq 0) {
    Write-Host "No user mailboxes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) user mailbox record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
