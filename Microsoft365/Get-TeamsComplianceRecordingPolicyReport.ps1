<#
.SYNOPSIS
Reports on Microsoft Teams compliance recording policies.

.DESCRIPTION
This script inventories compliance recording policies for regulated environments.

.EXAMPLE
.\Get-TeamsComplianceRecordingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving compliance recording policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsComplianceRecordingPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity    = $policy.Identity
        Description = $policy.Description
        Enabled     = $policy.Enabled
    }
}

Write-Host "Retrieved $($report.Count) compliance recording policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
