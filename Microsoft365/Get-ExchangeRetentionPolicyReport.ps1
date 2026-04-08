<#
.SYNOPSIS
Reports on Exchange Online retention policies.

.DESCRIPTION
This script inventories retention policies used by Exchange Online mailboxes.

.EXAMPLE
.\Get-ExchangeRetentionPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving retention policies..." -ForegroundColor Cyan
$policies = Get-RetentionPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Name           = $policy.Name
        RetentionId    = $policy.RetentionId
        IsDefault      = $policy.IsDefault
        IsValid        = $policy.IsValid
        RetentionPolicyTagLinks = ($policy.RetentionPolicyTagLinks -join ", ")
    }
}

if ($report.Count -eq 0) {
    Write-Host "No retention policies found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) retention policy record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
