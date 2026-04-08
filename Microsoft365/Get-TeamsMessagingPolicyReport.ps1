<#
.SYNOPSIS
Reports on Microsoft Teams messaging policies.

.DESCRIPTION
This script inventories messaging policies for Teams chat governance.

.EXAMPLE
.\Get-TeamsMessagingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving messaging policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsMessagingPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity       = $policy.Identity
        AllowGiphy     = $policy.AllowGiphy
        AllowMemes     = $policy.AllowMemes
        AllowStickers  = $policy.AllowStickers
        AllowURLPreview = $policy.AllowUrlPreviews
    }
}

Write-Host "Retrieved $($report.Count) messaging policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
