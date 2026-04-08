<#
.SYNOPSIS
Reports on Microsoft Teams meeting policy assignment coverage.

.DESCRIPTION
This script summarizes meeting policy assignments across Teams users.

.EXAMPLE
.\Get-TeamsMeetingAttendanceSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving Teams users..." -ForegroundColor Cyan
$users = Get-CsOnlineUser -ResultSize Unlimited

$report = foreach ($user in $users) {
    [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        DisplayName       = $user.DisplayName
        MeetingPolicy     = $user.TeamsMeetingPolicy
        MessagingPolicy   = $user.TeamsMessagingPolicy
    }
}

Write-Host "Retrieved $($report.Count) user policy assignment record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
