<#
.SYNOPSIS
Reports on system uptime and reboot age.

.DESCRIPTION
This script retrieves last boot time and uptime information for local or
remote computers and flags systems that may need a reboot.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER WarningThresholdDays
Number of uptime days after which a warning is flagged. Default is 30.

.EXAMPLE
.\Get-SystemUptimeAndRebootReport.ps1 -ComputerName "Server01" -WarningThresholdDays 21

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
    [int]$WarningThresholdDays = 30
)

Write-Host "Retrieving system uptime and reboot information..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        $uptime = (Get-Date) - $os.LastBootUpTime

        [PSCustomObject]@{
            ComputerName       = $computer
            LastBootTime       = $os.LastBootUpTime
            UptimeDays         = [math]::Round($uptime.TotalDays, 1)
            UptimeHours        = [math]::Round($uptime.TotalHours, 1)
            RebootRecommended  = if ($uptime.TotalDays -ge $WarningThresholdDays) { $true } else { $false }
            Status             = if ($uptime.TotalDays -ge $WarningThresholdDays) { "WARNING" } else { "OK" }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No uptime data collected." -ForegroundColor Yellow
}
else {
    $warnings = ($report | Where-Object { $_.Status -eq "WARNING" }).Count
    Write-Host "Retrieved $($report.Count) uptime record(s)." -ForegroundColor Green
    if ($warnings -gt 0) {
        Write-Host "WARNING: $warnings computer(s) exceed $WarningThresholdDays day(s) of uptime." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
