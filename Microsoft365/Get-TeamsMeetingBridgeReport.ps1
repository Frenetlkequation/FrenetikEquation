<#
.SYNOPSIS
Reports on Microsoft Teams meeting bridges.

.DESCRIPTION
This script inventories dial-in conferencing bridges for meeting operations.

.EXAMPLE
.\Get-TeamsMeetingBridgeReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving meeting bridges..." -ForegroundColor Cyan
$bridges = Get-CsOnlineDialInConferencingBridge

$report = foreach ($bridge in $bridges) {
    [PSCustomObject]@{
        Identity    = $bridge.Identity
        Name        = $bridge.Name
        BridgeType  = $bridge.BridgeType
        Region      = $bridge.Region
    }
}

Write-Host "Retrieved $($report.Count) meeting bridge record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
