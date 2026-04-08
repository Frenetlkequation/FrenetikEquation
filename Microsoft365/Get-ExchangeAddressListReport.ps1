<#
.SYNOPSIS
Reports on Exchange Online address lists.

.DESCRIPTION
This script inventories address lists to support Exchange organization review.

.EXAMPLE
.\Get-ExchangeAddressListReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving address lists..." -ForegroundColor Cyan
$lists = Get-AddressList

$report = foreach ($list in $lists) {
    [PSCustomObject]@{
        Name             = $list.Name
        DisplayName      = $list.DisplayName
        IncludedRecipients = $list.RecipientFilter
        ContainerPath    = $list.ContainerPath
    }
}

if ($report.Count -eq 0) {
    Write-Host "No address lists found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) address list(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
