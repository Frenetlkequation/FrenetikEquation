<#
.SYNOPSIS
Reports on scheduled task triggers.

.DESCRIPTION
This script inventories scheduled task triggers for automation review.

.EXAMPLE
.\Get-ScheduledTaskTriggerReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving scheduled task triggers..." -ForegroundColor Cyan

$report = Get-ScheduledTask -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        TaskName = $_.TaskName
        TaskPath = $_.TaskPath
        TriggerCount = @($_.Triggers).Count
        Triggers = if ($_.Triggers) { ($_.Triggers | ForEach-Object { $_.TriggerType }) -join ', ' } else { 'None' }
    }
}

Write-Host "Scheduled task triggers retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
