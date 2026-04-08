<#
.SYNOPSIS
Reports on Microsoft Teams channel policies.

.DESCRIPTION
This script inventories channel policies for collaboration governance.

.EXAMPLE
.\Get-TeamsChannelPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving channel policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsChannelsPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity             = $policy.Identity
        AllowGiphy            = $policy.AllowGiphy
        AllowMemes            = $policy.AllowMemes
        AllowStickersAndGifs  = $policy.AllowStickersAndGifs
        AllowUserCreateUpdateChannels = $policy.AllowUserCreateUpdateChannels
    }
}

Write-Host "Retrieved $($report.Count) channel policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
