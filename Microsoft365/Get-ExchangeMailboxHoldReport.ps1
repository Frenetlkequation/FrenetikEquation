<#
.SYNOPSIS
Reports on Exchange Online mailbox hold status.

.DESCRIPTION
This script reviews litigation hold and retention hold settings on mailboxes.

.EXAMPLE
.\Get-ExchangeMailboxHoldReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox hold settings..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -PropertySets All

$report = foreach ($mailbox in $mailboxes) {
    [PSCustomObject]@{
        DisplayName         = $mailbox.DisplayName
        UserPrincipalName   = $mailbox.UserPrincipalName
        LitigationHold      = $mailbox.LitigationHoldEnabled
        LitigationHoldDate  = $mailbox.LitigationHoldDate
        RetentionHold       = $mailbox.RetentionHoldEnabled
        InPlaceHolds        = ($mailbox.InPlaceHolds -join ", ")
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mailbox hold settings found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) mailbox hold record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
