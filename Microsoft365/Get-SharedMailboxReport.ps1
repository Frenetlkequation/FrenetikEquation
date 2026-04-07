<#
.SYNOPSIS
Reports on shared mailboxes in Exchange Online.

.DESCRIPTION
This script retrieves shared mailbox information including size, permissions,
and forwarding status for administrative review and auditing.

.EXAMPLE
.\Get-SharedMailboxReport.ps1

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

Write-Host "Retrieving shared mailboxes..." -ForegroundColor Cyan

$sharedMailboxes = Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited

$report = foreach ($mbx in $sharedMailboxes) {
    $stats = Get-EXOMailboxStatistics -Identity $mbx.UserPrincipalName -ErrorAction SilentlyContinue
    $permissions = Get-EXOMailboxPermission -Identity $mbx.UserPrincipalName |
        Where-Object { $_.User -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false }

    $delegateList = ($permissions | ForEach-Object { $_.User }) -join "; "

    [PSCustomObject]@{
        DisplayName        = $mbx.DisplayName
        PrimarySmtpAddress = $mbx.PrimarySmtpAddress
        TotalItemSize      = $stats.TotalItemSize
        ItemCount          = $stats.ItemCount
        Delegates          = if ($delegateList) { $delegateList } else { "None" }
        ForwardingAddress  = $mbx.ForwardingSmtpAddress
        WhenCreated        = $mbx.WhenCreated
    }
}

if ($report.Count -eq 0) {
    Write-Host "No shared mailboxes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) shared mailbox(es)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
