<#
.SYNOPSIS
Reports on Microsoft Teams voice routes.

.DESCRIPTION
This script inventories voice routes for PSTN configuration review.

.EXAMPLE
.\Get-TeamsVoiceRouteReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving voice routes..." -ForegroundColor Cyan
$routes = Get-CsOnlineVoiceRoute

$report = foreach ($route in $routes) {
    [PSCustomObject]@{
        Identity   = $route.Identity
        Name       = $route.Name
        NumberPattern = $route.NumberPattern
        OnlinePstnGatewayList = ($route.OnlinePstnGatewayList -join ", ")
    }
}

Write-Host "Retrieved $($report.Count) voice route record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
