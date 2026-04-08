<#
.SYNOPSIS
Reports on BranchCache configuration.

.DESCRIPTION
This script inventories BranchCache settings and feature status for local or remote computers.

.EXAMPLE
.\Get-BranchCacheConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving BranchCache configuration..." -ForegroundColor Cyan

$feature = Get-WindowsFeature -Name BranchCache -ErrorAction SilentlyContinue
$status = Get-BCStatus -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    FeatureInstalled = if ($feature) { $feature.Installed } else { $false }
    ServiceMode      = if ($status) { $status.Mode } else { "Unknown" }
    HostedCache      = if ($status) { $status.HostedCacheServerStatus } else { "Unknown" }
    DistributedCache = if ($status) { $status.DistributedCacheMode } else { "Unknown" }
}

Write-Host "BranchCache configuration retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
