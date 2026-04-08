<#
.SYNOPSIS
Reports on Microsoft 365 mailbox delegation.

.DESCRIPTION
This script summarizes mailbox delegation permissions for access review.

.EXAMPLE
.\Get-M365MailboxDelegationSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailboxes..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox

$report = foreach ($mailbox in $mailboxes) {
    $permissions = Get-MailboxPermission -Identity $mailbox.UserPrincipalName -ErrorAction SilentlyContinue |
        Where-Object { -not $_.IsInherited -and $_.User -notmatch "NT AUTHORITY|SELF" }

    [PSCustomObject]@{
        Mailbox      = $mailbox.UserPrincipalName
        DelegateCount = @($permissions).Count
        MailboxType  = $mailbox.RecipientTypeDetails
    }
}

Write-Host "Retrieved $($report.Count) mailbox delegation record(s)." -ForegroundColor Green
$report | Sort-Object DelegateCount -Descending | Format-Table -AutoSize
