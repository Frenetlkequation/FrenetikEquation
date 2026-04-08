<#
.SYNOPSIS
Reports on Microsoft Teams federation configuration.

.DESCRIPTION
This script inventories federation settings used for external collaboration.

.EXAMPLE
.\Get-TeamsFederationConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving federation configuration..." -ForegroundColor Cyan
$config = Get-CsTenantFederationConfiguration

$report = [PSCustomObject]@{
    AllowFederatedUsers = $config.AllowFederatedUsers
    AllowTeamsConsumer  = $config.AllowTeamsConsumer
    SharedSipAddressSpace = $config.SharedSipAddressSpace
}

Write-Host "Retrieved Teams federation configuration." -ForegroundColor Green
$report | Format-Table -AutoSize
