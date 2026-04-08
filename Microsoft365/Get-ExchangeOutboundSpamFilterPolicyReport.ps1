<#
.SYNOPSIS
Reports on Exchange Online outbound spam filter policies.

.DESCRIPTION
This script reviews outbound spam filter settings for mail protection governance.

.EXAMPLE
.\Get-ExchangeOutboundSpamFilterPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving outbound spam filter policies..." -ForegroundColor Cyan
$policies = Get-HostedOutboundSpamFilterPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Name                  = $policy.Name
        Enabled               = $policy.Enabled
        NotifyOutboundSpam     = $policy.NotifyOutboundSpam
        RecipientLimitExternal = $policy.RecipientLimitExternalPerHour
        Action                = $policy.ActionWhenThresholdReached
    }
}

if ($report.Count -eq 0) {
    Write-Host "No outbound spam filter policies found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) outbound spam policy record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
