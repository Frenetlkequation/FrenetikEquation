<#
.SYNOPSIS
Reports on Exchange Online distribution group membership.

.DESCRIPTION
This script summarizes distribution groups and their member counts for governance review.

.EXAMPLE
.\Get-ExchangeDistributionGroupMemberSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving distribution groups..." -ForegroundColor Cyan
$groups = Get-DistributionGroup -ResultSize Unlimited

$report = foreach ($group in $groups) {
    $members = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        DisplayName  = $group.DisplayName
        Alias        = $group.Alias
        ManagedBy    = ($group.ManagedBy -join ", ")
        MemberCount  = @($members).Count
        HiddenFromGAL = $group.HiddenFromAddressListsEnabled
    }
}

if ($report.Count -eq 0) {
    Write-Host "No distribution groups found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) distribution group(s)." -ForegroundColor Green
    $report | Sort-Object MemberCount -Descending | Format-Table -AutoSize
}
