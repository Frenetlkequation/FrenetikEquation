<#
.SYNOPSIS
Reports on Windows event log errors and warnings.

.DESCRIPTION
This script queries the System and Application event logs on specified servers
for recent error and warning events to support troubleshooting and proactive
monitoring.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER Hours
Number of hours to look back in event logs. Default is 24.

.PARAMETER LogName
Event log names to query. Default is System and Application.

.EXAMPLE
.\Get-EventLogReport.ps1 -ComputerName "Server01" -Hours 48

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
    [string[]]$ComputerName = $env:COMPUTERNAME,

    [Parameter()]
    [int]$Hours = 24,

    [Parameter()]
    [string[]]$LogName = @("System", "Application")
)

$startTime = (Get-Date).AddHours(-$Hours)

Write-Host "Retrieving event log entries from the last $Hours hour(s)..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    foreach ($log in $LogName) {
        Write-Host "  Querying $log log on $computer..." -ForegroundColor Cyan

        try {
            $events = Get-WinEvent -ComputerName $computer -FilterHashtable @{
                LogName   = $log
                Level     = @(1, 2, 3)  # Critical, Error, Warning
                StartTime = $startTime
            } -ErrorAction SilentlyContinue

            foreach ($event in $events) {
                $levelName = switch ($event.Level) {
                    1 { "Critical" }
                    2 { "Error" }
                    3 { "Warning" }
                }

                [PSCustomObject]@{
                    ComputerName = $computer
                    LogName      = $log
                    Level        = $levelName
                    EventId      = $event.Id
                    Source       = $event.ProviderName
                    TimeCreated  = $event.TimeCreated
                    Message      = ($event.Message -split "`n")[0]
                }
            }
        }
        catch {
            Write-Warning "Failed to query $log on $computer : $_"
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No error or warning events found." -ForegroundColor Green
}
else {
    $critical = ($report | Where-Object { $_.Level -eq "Critical" }).Count
    $errors = ($report | Where-Object { $_.Level -eq "Error" }).Count
    $warnings = ($report | Where-Object { $_.Level -eq "Warning" }).Count

    Write-Host "Found $($report.Count) event(s). Critical: $critical, Errors: $errors, Warnings: $warnings" -ForegroundColor Green
    $report | Sort-Object TimeCreated -Descending | Format-Table -AutoSize
}
