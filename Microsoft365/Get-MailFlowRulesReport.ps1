<#
.SYNOPSIS
Reports on mail transport rules in Exchange Online.

.DESCRIPTION
This script retrieves mail flow (transport) rules from Exchange Online and
reports on their priority, state, and conditions for governance and security review.

.EXAMPLE
.\Get-MailFlowRulesReport.ps1

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

Write-Host "Retrieving mail flow rules..." -ForegroundColor Cyan

$rules = Get-TransportRule

$report = foreach ($rule in $rules) {
    [PSCustomObject]@{
        Name              = $rule.Name
        State             = $rule.State
        Priority          = $rule.Priority
        Mode              = $rule.Mode
        SenderDomains     = ($rule.SenderDomainIs -join ", ")
        RecipientDomains  = ($rule.RecipientDomainIs -join ", ")
        FromScope         = $rule.FromScope
        SentToScope       = $rule.SentToScope
        HasExceptions     = ($null -ne $rule.ExceptIfSenderDomainIs -or $null -ne $rule.ExceptIfRecipientDomainIs)
        Comments          = $rule.Comments
        WhenChanged       = $rule.WhenChanged
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mail flow rules found." -ForegroundColor Yellow
}
else {
    $enabled = ($report | Where-Object { $_.State -eq "Enabled" }).Count
    $disabled = ($report | Where-Object { $_.State -eq "Disabled" }).Count

    Write-Host "Retrieved $($report.Count) mail flow rule(s). Enabled: $enabled, Disabled: $disabled" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
