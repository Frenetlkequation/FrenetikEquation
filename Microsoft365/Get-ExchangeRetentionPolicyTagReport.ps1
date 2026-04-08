<#
.SYNOPSIS
Reports on Exchange Online retention policy tags.

.DESCRIPTION
This script inventories retention tags for Exchange Online retention governance.

.EXAMPLE
.\Get-ExchangeRetentionPolicyTagReport.ps1

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
        Name                 = $tag.Name
        Type                 = $tag.Type
        RetentionEnabled     = $tag.RetentionEnabled
        AgeLimitForRetention = $tag.AgeLimitForRetention
        RetentionAction      = $tag.RetentionAction
    }
}

if ($report.Count -eq 0) {
    Write-Host "No retention policy tags found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) retention tag record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
