<#
.SYNOPSIS
Reports on Microsoft Teams external access configuration.

.DESCRIPTION
This script reviews tenant external access settings for collaboration governance.

.EXAMPLE
.\Get-TeamsExternalAccessConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving tenant federation configuration..." -ForegroundColor Cyan
$config = Get-CsTenantFederationConfiguration

$report = [PSCustomObject]@{
    AllowFederatedUsers             = $config.AllowFederatedUsers
    AllowPublicUsers                = $config.AllowPublicUsers
    TreatDiscoveredPartnersAsUnauthenticated = $config.TreatDiscoveredPartnersAsUnauthenticated
}

Write-Host "Retrieved Teams external access configuration." -ForegroundColor Green
$report | Format-Table -AutoSize
