<#
.SYNOPSIS
Reports on Exchange Online message trace activity.

.DESCRIPTION
This script summarizes recent message trace data for mail flow visibility.

.EXAMPLE
.\Get-ExchangeMessageTraceSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param (
    [Parameter()]
    [int]$Days = 1
)

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

$start = (Get-Date).AddDays(-$Days)
$end = Get-Date

Write-Host "Retrieving message trace data..." -ForegroundColor Cyan
$trace = Get-MessageTrace -StartDate $start -EndDate $end -PageSize 5000 -ErrorAction SilentlyContinue

$report = foreach ($item in $trace) {
    [PSCustomObject]@{
        Received            = $item.Received
        SenderAddress       = $item.SenderAddress
        RecipientAddress    = $item.RecipientAddress
        Status              = $item.Status
        MessageSubject      = $item.Subject
    }
}

if ($report.Count -eq 0) {
    Write-Host "No message trace data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) message trace record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
