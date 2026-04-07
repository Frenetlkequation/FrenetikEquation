<#
.SYNOPSIS
Retrieves and reports mailbox information from Exchange Online.

.DESCRIPTION
This script queries Exchange Online for mailbox data and produces a report
for administrative review and operational auditing.

.EXAMPLE
.\Get-MailboxReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox information..." -ForegroundColor Cyan

$mailboxes = Get-EXOMailbox -ResultSize Unlimited -PropertySets All |
    Select-Object DisplayName, UserPrincipalName, PrimarySmtpAddress, RecipientTypeDetails,
        WhenCreated, IsMailboxEnabled, ArchiveStatus, RetentionPolicy

$stats = foreach ($mbx in $mailboxes) {
    $mbxStats = Get-EXOMailboxStatistics -Identity $mbx.UserPrincipalName -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        DisplayName        = $mbx.DisplayName
        UserPrincipalName  = $mbx.UserPrincipalName
        PrimarySmtpAddress = $mbx.PrimarySmtpAddress
        MailboxType        = $mbx.RecipientTypeDetails
        TotalItemSize      = $mbxStats.TotalItemSize
        ItemCount          = $mbxStats.ItemCount
        IsEnabled          = $mbx.IsMailboxEnabled
        ArchiveStatus      = $mbx.ArchiveStatus
        WhenCreated        = $mbx.WhenCreated
    }
}

if ($stats.Count -eq 0) {
    Write-Host "No mailboxes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($stats.Count) mailbox(es)." -ForegroundColor Green
    $stats | Format-Table -AutoSize
}
