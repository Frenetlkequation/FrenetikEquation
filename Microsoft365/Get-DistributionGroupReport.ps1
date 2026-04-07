<#
.SYNOPSIS
Reports on Microsoft 365 distribution groups and their members.

.DESCRIPTION
This script retrieves distribution groups from Exchange Online and reports
on membership, owner, and configuration for administrative review and cleanup.

.EXAMPLE
.\Get-DistributionGroupReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
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
        DisplayName        = $group.DisplayName
        PrimarySmtpAddress = $group.PrimarySmtpAddress
        GroupType          = $group.GroupType
        ManagedBy          = ($group.ManagedBy -join "; ")
        MemberCount        = $members.Count
        HiddenFromGAL      = $group.HiddenFromAddressListsEnabled
        RequireSenderAuth  = $group.RequireSenderAuthenticationEnabled
        WhenCreated        = $group.WhenCreated
    }
}

if ($report.Count -eq 0) {
    Write-Host "No distribution groups found." -ForegroundColor Yellow
}
else {
    $emptyGroups = ($report | Where-Object { $_.MemberCount -eq 0 }).Count
    Write-Host "Retrieved $($report.Count) distribution group(s). Empty: $emptyGroups" -ForegroundColor Green
    $report | Sort-Object DisplayName | Format-Table -AutoSize
}
