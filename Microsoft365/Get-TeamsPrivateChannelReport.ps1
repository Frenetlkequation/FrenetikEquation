<#
.SYNOPSIS
Reports on Microsoft Teams private channels.

.DESCRIPTION
This script inventories private channels in Teams for collaboration review.

.EXAMPLE
.\Get-TeamsPrivateChannelReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving Teams..." -ForegroundColor Cyan
$teams = Get-Team

$report = foreach ($team in $teams) {
    $channels = Get-TeamChannel -GroupId $team.GroupId -ErrorAction SilentlyContinue | Where-Object { $_.MembershipType -eq "Private" }
    foreach ($channel in @($channels)) {
        [PSCustomObject]@{
            TeamName      = $team.DisplayName
            ChannelName   = $channel.DisplayName
            MembershipType = $channel.MembershipType
            Description   = $channel.Description
        }
    }
}

Write-Host "Retrieved $($report.Count) private channel record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
