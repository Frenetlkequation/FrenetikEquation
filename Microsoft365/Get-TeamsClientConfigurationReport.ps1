<#
.SYNOPSIS
Reports on Microsoft Teams client configuration.

.DESCRIPTION
This script inventories client configuration settings for Teams administrators.

.EXAMPLE
.\Get-TeamsClientConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving client configuration..." -ForegroundColor Cyan
$config = Get-CsTeamsClientConfiguration

$report = [PSCustomObject]@{
    Identity                  = $config.Identity
    AllowEmailIntoClient      = $config.AllowEmailIntoClient
    AllowGuestMeetingJoin     = $config.AllowGuestMeetingJoin
    AllowImmersiveReader      = $config.AllowImmersiveReader
    AllowPrivateCalling       = $config.AllowPrivateCalling
}

Write-Host "Retrieved Teams client configuration." -ForegroundColor Green
$report | Format-Table -AutoSize
