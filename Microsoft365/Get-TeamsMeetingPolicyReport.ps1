<#
.SYNOPSIS
Reports on Microsoft Teams meeting policies.

.DESCRIPTION
This script inventories meeting policies for collaboration governance.

.EXAMPLE
.\Get-TeamsMeetingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving meeting policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsMeetingPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity               = $policy.Identity
        AllowIPVideo            = $policy.AllowIPVideo
        AllowMeetNow            = $policy.AllowMeetNow
        AllowCloudRecording     = $policy.AllowCloudRecording
        AllowTranscription      = $policy.AllowTranscription
    }
}

Write-Host "Retrieved $($report.Count) meeting policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
