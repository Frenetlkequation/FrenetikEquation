<#
.SYNOPSIS
Reports on scheduled task status.

.DESCRIPTION
This script retrieves scheduled task information from local or remote computers
and reports task state and last run details for operational review.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-ScheduledTaskStatusReport.ps1 -ComputerName "Server01"

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied,
    including but not limited to the warranties of merchantability, fitness for a
    particular purpose, and noninfringement.

    In no event shall the authors, contributors, or copyright holders (FrenetikEquation)
    be liable for any claim, damages, or other liability, whether in an action of
    contract, tort, or otherwise, arising from, out of, or in connection with this
    script or the use or other dealings in this script. This includes, without
    limitation, any direct, indirect, incidental, special, exemplary, or consequential
    damages, including but not limited to loss of data, loss of revenue, business
    interruption, or damage to systems.

    USE AT YOUR OWN RISK. You are solely responsible for testing this script in a
    non-production environment before deploying to any production system. The user
    assumes all responsibility and risk for the use of this script. It is strongly
    recommended that you review, understand, and validate the script logic before
    execution.

    By using this script, you acknowledge and agree to these terms. If you do not
    agree, do not use this script. Refer to the LICENSE file in the root of this
    repository for the full license terms.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string[]]$ComputerName = $env:COMPUTERNAME
)

#Requires -Module ScheduledTasks

Write-Host "Retrieving scheduled task status..." -ForegroundColor Cyan

$scriptBlock = {
    Get-ScheduledTask | ForEach-Object {
        $info = Get-ScheduledTaskInfo -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue

        [PSCustomObject]@{
            ComputerName   = $env:COMPUTERNAME
            TaskName       = $_.TaskName
            TaskPath       = $_.TaskPath
            State          = $_.State
            LastRunTime    = $info.LastRunTime
            LastTaskResult = $info.LastTaskResult
            NextRunTime    = $info.NextRunTime
        }
    }
}

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        if ($computer -in @($env:COMPUTERNAME, 'localhost', '.')) {
            & $scriptBlock
        }
        else {
            Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ErrorAction Stop
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No scheduled task data collected." -ForegroundColor Yellow
}
else {
    $stopped = ($report | Where-Object { $_.State -ne 'Ready' -and $_.State -ne 'Running' }).Count
    Write-Host "Retrieved $($report.Count) task record(s)." -ForegroundColor Green
    if ($stopped -gt 0) {
        Write-Host "  WARNING: $stopped task(s) are not in a healthy state." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
