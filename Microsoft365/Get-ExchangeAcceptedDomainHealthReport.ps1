<#
.SYNOPSIS
Reports on Exchange Online accepted domains.

.DESCRIPTION
This script inventories accepted domains and their configuration for mail routing review.

.EXAMPLE
.\Get-ExchangeAcceptedDomainHealthReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving accepted domains..." -ForegroundColor Cyan
$domains = Get-AcceptedDomain

$report = foreach ($domain in $domains) {
    [PSCustomObject]@{
        Name            = $domain.Name
        DomainName      = $domain.DomainName
        DomainType      = $domain.DomainType
        Default         = $domain.Default
        InitialDomain   = $domain.InitialDomain
        MatchSubDomains = $domain.MatchSubDomains
    }
}

if ($report.Count -eq 0) {
    Write-Host "No accepted domains found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) accepted domain(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
