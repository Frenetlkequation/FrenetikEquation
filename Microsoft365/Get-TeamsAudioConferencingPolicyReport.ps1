<#
.SYNOPSIS
Reports on Microsoft Teams audio conferencing policies.

.DESCRIPTION
This script inventories audio conferencing policies for meeting governance.

.EXAMPLE
.\Get-TeamsAudioConferencingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving audio conferencing policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsAudioConferencingPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity      = $policy.Identity
        Description   = $policy.Description
        Enabled       = $policy.Enabled
        TollFree     = $policy.EnableTollFree
    }
}

Write-Host "Retrieved $($report.Count) audio conferencing policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
