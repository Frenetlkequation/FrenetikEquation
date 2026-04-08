<#
.SYNOPSIS
Reports on Microsoft Teams emergency calling policies.

.DESCRIPTION
This script inventories emergency calling policies for voice governance.

.EXAMPLE
.\Get-TeamsEmergencyCallingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving emergency calling policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsEmergencyCallingPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity    = $policy.Identity
        Description = $policy.Description
        Enabled     = $policy.Enabled
    }
}

Write-Host "Retrieved $($report.Count) emergency calling policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
