<#
.SYNOPSIS
Reports on Microsoft 365 spam filter policies.

.DESCRIPTION
This script inventories Exchange anti-spam policies for mail protection review.

.EXAMPLE
.\Get-M365SpamFilterPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving anti-spam policies..." -ForegroundColor Cyan
$policies = Get-HostedContentFilterPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Name       = $policy.Name
        Enabled    = $policy.Enabled
        BulkThreshold = $policy.BulkThreshold
        SpamAction = $policy.SpamAction
    }
}

Write-Host "Retrieved $($report.Count) spam filter policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
