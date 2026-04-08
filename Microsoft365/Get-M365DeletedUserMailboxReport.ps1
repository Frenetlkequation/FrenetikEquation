<#
.SYNOPSIS
Reports on deleted user mailboxes in Microsoft 365.

.DESCRIPTION
This script inventories soft-deleted user mailboxes for recovery review.

.EXAMPLE
.\Get-M365DeletedUserMailboxReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving soft-deleted user mailboxes..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -SoftDeletedMailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited

$report = foreach ($mailbox in $mailboxes) {
    [PSCustomObject]@{
        DisplayName       = $mailbox.DisplayName
        UserPrincipalName  = $mailbox.UserPrincipalName
        WhenSoftDeleted    = $mailbox.WhenSoftDeleted
    }
}

Write-Host "Retrieved $($report.Count) deleted user mailbox record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
