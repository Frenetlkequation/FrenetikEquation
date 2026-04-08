<#
.SYNOPSIS
Reports on Microsoft 365 retention labels.

.DESCRIPTION
This script inventories Exchange retention tags used for data lifecycle control.

.EXAMPLE
.\Get-M365RetentionLabelReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving retention policy tags..." -ForegroundColor Cyan
$tags = Get-RetentionPolicyTag

$report = foreach ($tag in $tags) {
    [PSCustomObject]@{
        Name               = $tag.Name
        Type               = $tag.Type
        RetentionAction    = $tag.RetentionAction
        AgeLimitForRetention = $tag.AgeLimitForRetention
    }
}

Write-Host "Retrieved $($report.Count) retention label record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
