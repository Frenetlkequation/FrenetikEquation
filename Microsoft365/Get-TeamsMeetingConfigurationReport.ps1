<#
.SYNOPSIS
Reports on Microsoft Teams meeting configuration.

.DESCRIPTION
This script inventories meeting configuration settings for governance review.

.EXAMPLE
.\Get-TeamsMeetingConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving meeting configuration..." -ForegroundColor Cyan
$config = Get-CsTeamsMeetingConfiguration

$report = [PSCustomObject]@{
    Identity                 = $config.Identity
    AllowAnonymousUsersToStartMeeting = $config.AllowAnonymousUsersToStartMeeting
    AllowPSTNCallingForMeetings = $config.AllowPSTNCallingForMeetings
    AllowCloudRecording      = $config.AllowCloudRecording
    AllowEngagementReport    = $config.AllowEngagementReport
}

Write-Host "Retrieved Teams meeting configuration." -ForegroundColor Green
$report | Format-Table -AutoSize
