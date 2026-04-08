<#
.SYNOPSIS
Reports on Windows event log channel configuration.

.DESCRIPTION
This script inventories event log channel settings such as size, retention, and enabled state.

.EXAMPLE
.\Get-EventLogChannelConfigurationReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string[]]$LogName = @('System', 'Application')
)

Write-Host "Retrieving event log channel configuration..." -ForegroundColor Cyan

$report = foreach ($log in $LogName) {
    try {
        $channel = Get-WinEvent -ListLog $log -ErrorAction Stop
        [PSCustomObject]@{
            LogName           = $channel.LogName
            IsEnabled         = $channel.IsEnabled
            MaximumSizeInBytes = $channel.MaximumSizeInBytes
            LogMode           = $channel.LogMode
            RecordCount       = $channel.RecordCount
        }
    }
    catch {
        Write-Warning "Failed to query $log : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No event log channel data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected event log channel data for $($report.Count) channel(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
