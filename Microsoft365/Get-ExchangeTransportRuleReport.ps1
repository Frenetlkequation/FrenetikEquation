<#
.SYNOPSIS
Reports on Exchange Online transport rules.

.DESCRIPTION
This script inventories mail flow rules for Exchange Online governance.

.EXAMPLE
.\Get-ExchangeTransportRuleReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving transport rules..." -ForegroundColor Cyan
$rules = Get-TransportRule

$report = foreach ($rule in $rules) {
    [PSCustomObject]@{
        Name              = $rule.Name
        State             = $rule.State
        Priority          = $rule.Priority
        Mode              = $rule.Mode
        Comments          = $rule.Comments
        SentTo            = ($rule.SentTo -join ", ")
    }
}

if ($report.Count -eq 0) {
    Write-Host "No transport rules found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) transport rule record(s)." -ForegroundColor Green
    $report | Sort-Object Priority | Format-Table -AutoSize
}
