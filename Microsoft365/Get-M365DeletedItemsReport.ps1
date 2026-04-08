<#
.SYNOPSIS
Reports on deleted Microsoft 365 mailboxes.

.DESCRIPTION
This script inventories soft-deleted mailboxes for recovery review.

.EXAMPLE
.\Get-M365DeletedItemsReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving soft-deleted mailboxes..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -SoftDeletedMailbox -ResultSize Unlimited

$report = foreach ($mailbox in $mailboxes) {
    [PSCustomObject]@{
        DisplayName       = $mailbox.DisplayName
        UserPrincipalName = $mailbox.UserPrincipalName
        RecipientType     = $mailbox.RecipientTypeDetails
        ArchiveStatus     = $mailbox.ArchiveStatus
    }
}

Write-Host "Retrieved $($report.Count) deleted mailbox record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
