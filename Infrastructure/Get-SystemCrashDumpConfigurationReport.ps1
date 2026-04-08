<#
.SYNOPSIS
Reports on system crash dump configuration.

.DESCRIPTION
This script inventories crash dump settings for the local Windows system.

.EXAMPLE
.\Get-SystemCrashDumpConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving crash dump configuration..." -ForegroundColor Cyan

$dump = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    CrashDumpEnabled = if ($dump) { $dump.CrashDumpEnabled } else { 'Unknown' }
    DumpFile         = if ($dump) { $dump.DumpFile } else { 'Unknown' }
    MinidumpDir      = if ($dump) { $dump.MinidumpDir } else { 'Unknown' }
    Overwrite        = if ($dump) { $dump.Overwrite } else { 'Unknown' }
}

Write-Host "Crash dump configuration retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
