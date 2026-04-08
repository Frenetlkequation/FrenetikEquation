<#
.SYNOPSIS
Reports on Microsoft Teams room policies.

.DESCRIPTION
This script inventories Teams room policies for device governance.

.EXAMPLE
.\Get-TeamsRoomPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving room policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsRoomPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity   = $policy.Identity
        Description = $policy.Description
        AllowCamera = $policy.AllowCamera
        AllowContentCamera = $policy.AllowContentCamera
    }
}

Write-Host "Retrieved $($report.Count) room policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
