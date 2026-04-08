<#
.SYNOPSIS
Reports on Microsoft Teams guest access configuration.

.DESCRIPTION
This script reviews guest access settings for Teams governance.

.EXAMPLE
.\Get-TeamsGuestAccessConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving guest access configuration..." -ForegroundColor Cyan
$tenant = Get-CsTenant

$report = [PSCustomObject]@{
    AllowGuestAccess = $tenant.AllowGuestAccess
    AllowAnonymousMeetingJoin = $tenant.AllowAnonymousMeetingJoin
    AllowGuestMeetingChat = $tenant.AllowGuestMeetingChat
}

Write-Host "Retrieved Teams guest access configuration." -ForegroundColor Green
$report | Format-Table -AutoSize
