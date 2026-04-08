<#
.SYNOPSIS
Reports on Microsoft Teams org-wide policy assignment coverage.

.DESCRIPTION
This script inventories policy assignments applied to Teams users tenant-wide.

.EXAMPLE
.\Get-TeamsOrgWidePolicyAssignmentReport.ps1

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
        VoicePolicy       = $user.VoicePolicy
        TeamsAppPolicy    = $user.TeamsAppPermissionPolicy
        TeamsUpgrade     = $user.TeamsUpgradePolicy
    }
}

Write-Host "Retrieved $($report.Count) org-wide policy assignment record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
