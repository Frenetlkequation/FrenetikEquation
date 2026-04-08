<#
.SYNOPSIS
Reports on Exchange Online shared mailbox delegation.

.DESCRIPTION
This script inventories shared mailbox permissions for access review.

.EXAMPLE
.\Get-ExchangeSharedMailboxDelegationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving shared mailboxes..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox

$report = foreach ($mailbox in $mailboxes) {
    $permissions = Get-MailboxPermission -Identity $mailbox.UserPrincipalName -ErrorAction SilentlyContinue |
        Where-Object { -not $_.IsInherited -and $_.User -notmatch "NT AUTHORITY|SELF" }

    [PSCustomObject]@{
        DisplayName       = $mailbox.DisplayName
        UserPrincipalName = $mailbox.UserPrincipalName
        DelegateCount     = @($permissions).Count
        ArchiveStatus     = $mailbox.ArchiveStatus
    }
}

if ($report.Count -eq 0) {
    Write-Host "No shared mailboxes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) shared mailbox record(s)." -ForegroundColor Green
    $report | Sort-Object DelegateCount -Descending | Format-Table -AutoSize
}
