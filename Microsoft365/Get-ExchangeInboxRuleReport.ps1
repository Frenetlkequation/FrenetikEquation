<#
.SYNOPSIS
Reports on Exchange Online inbox rules.

.DESCRIPTION
This script inventories inbox rules for mailbox governance and mail flow review.

.EXAMPLE
.\Get-ExchangeInboxRuleReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox inbox rules..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox

$report = foreach ($mailbox in $mailboxes) {
    $rules = Get-InboxRule -Mailbox $mailbox.UserPrincipalName -ErrorAction SilentlyContinue
    foreach ($rule in @($rules)) {
        [PSCustomObject]@{
            Mailbox        = $mailbox.UserPrincipalName
            RuleName       = $rule.Name
            Enabled        = $rule.Enabled
            Priority       = $rule.Priority
            Description    = $rule.Description
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No inbox rules found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) inbox rule(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
