<#
.SYNOPSIS
Reports on scheduled task history summary.

.DESCRIPTION
This script summarizes scheduled task execution history for operational review.

.EXAMPLE
.\Get-ScheduledTaskHistorySummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving scheduled task history summary..." -ForegroundColor Cyan

$report = Get-ScheduledTask -ErrorAction SilentlyContinue | ForEach-Object {
    $info = Get-ScheduledTaskInfo -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        TaskName   = $_.TaskName
        TaskPath   = $_.TaskPath
        LastRunTime = if ($info) { $info.LastRunTime } else { $null }
        LastTaskResult = if ($info) { $info.LastTaskResult } else { $null }
        NextRunTime = if ($info) { $info.NextRunTime } else { $null }
    }
}

Write-Host "Scheduled task history summary retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
