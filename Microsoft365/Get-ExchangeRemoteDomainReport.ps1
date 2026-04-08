<#
.SYNOPSIS
Reports on Exchange Online remote domains.

.DESCRIPTION
This script inventories remote domain settings for mail flow review.

.EXAMPLE
.\Get-ExchangeRemoteDomainReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving remote domains..." -ForegroundColor Cyan
$domains = Get-RemoteDomain

$report = foreach ($domain in $domains) {
    [PSCustomObject]@{
        Name                   = $domain.Name
        DomainName             = $domain.DomainName
        AutoReplyEnabled       = $domain.AutoReplyEnabled
        DeliveryReportEnabled  = $domain.DeliveryReportEnabled
        TrustedMailInbound     = $domain.TrustInboundMail
    }
}

if ($report.Count -eq 0) {
    Write-Host "No remote domains found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) remote domain record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
