<#
.SYNOPSIS
Reports on backup policy status.

.DESCRIPTION
This script checks Windows Server Backup availability and basic backup policy indicators so administrators can confirm the backup posture on a server.

.EXAMPLE
.\Get-BackupPolicyStatusReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Checking backup policy status..." -ForegroundColor Cyan

$feature = Get-WindowsFeature -Name Windows-Server-Backup -ErrorAction SilentlyContinue
$service = Get-Service -Name wbengine -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    BackupFeatureInstalled = if ($feature) { $feature.Installed } else { $false }
    BackupFeatureName      = if ($feature) { $feature.Name } else { "Unknown" }
    BackupServiceState     = if ($service) { $service.Status } else { "NotFound" }
    BackupServiceStartType = if ($service) { $service.StartType } else { "Unknown" }
}

Write-Host "Backup policy status retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
