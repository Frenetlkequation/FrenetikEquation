<#
.SYNOPSIS
Reports on Microsoft Teams app permission policies.

.DESCRIPTION
This script inventories app permission policies for Teams governance.

.EXAMPLE
.\Get-TeamsAppPermissionPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving app permission policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsAppPermissionPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity      = $policy.Identity
        Description   = $policy.Description
        AllowUserApp  = $policy.AllowUserApp
        AllowUserPin  = $policy.AllowUserPin
    }
}

Write-Host "Retrieved $($report.Count) app permission policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
