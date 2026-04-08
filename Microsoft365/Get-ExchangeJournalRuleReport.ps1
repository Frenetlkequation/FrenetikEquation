<#
.SYNOPSIS
Reports on Exchange Online journal rules.

.DESCRIPTION
This script inventories journal rules for compliance and mail archiving review.

.EXAMPLE
.\Get-ExchangeJournalRuleReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving journal rules..." -ForegroundColor Cyan
$rules = Get-JournalRule

$report = foreach ($rule in $rules) {
    [PSCustomObject]@{
        Name             = $rule.Name
        Enabled          = $rule.Enabled
        JournalEmail     = $rule.JournalEmailAddress
        Scope            = $rule.JournalEmailScope
        Recipient        = $rule.Recipient
        RuleScope        = $rule.Scope
    }
}

if ($report.Count -eq 0) {
    Write-Host "No journal rules found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) journal rule(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
