<#
.SYNOPSIS
Reports on Exchange Online mailbox delegation.

.DESCRIPTION
This script inventories mailbox delegation permissions for access review.

.EXAMPLE
.\Get-ExchangeMailboxDelegationSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox delegation..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox

$report = foreach ($mailbox in $mailboxes) {
    $permissions = Get-MailboxPermission -Identity $mailbox.UserPrincipalName -ErrorAction SilentlyContinue |
        Where-Object { -not $_.IsInherited -and $_.User -notmatch "NT AUTHORITY|SELF" }

    [PSCustomObject]@{
        Mailbox           = $mailbox.UserPrincipalName
        DelegateCount     = @($permissions).Count
        DisplayName       = $mailbox.DisplayName
        RecipientType     = $mailbox.RecipientTypeDetails
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mailbox delegation records found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) mailbox delegation summary record(s)." -ForegroundColor Green
    $report | Sort-Object DelegateCount -Descending | Format-Table -AutoSize
}
