<#
.SYNOPSIS
Reports on Exchange Online archive mailbox status.

.DESCRIPTION
This script reviews archive-enabled mailboxes and their archive state.

.EXAMPLE
.\Get-ExchangeMailboxArchiveReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving archive-enabled mailboxes..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -PropertySets All | Where-Object { $_.ArchiveStatus -ne "None" }

$report = foreach ($mailbox in $mailboxes) {
    [PSCustomObject]@{
        DisplayName        = $mailbox.DisplayName
        UserPrincipalName  = $mailbox.UserPrincipalName
        ArchiveStatus      = $mailbox.ArchiveStatus
        ArchiveGuid        = $mailbox.ArchiveGuid
        ArchiveName        = $mailbox.ArchiveName
        ArchiveQuota       = $mailbox.ArchiveQuota
    }
}

if ($report.Count -eq 0) {
    Write-Host "No archive mailboxes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) archive mailbox record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
