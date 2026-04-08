<#
.SYNOPSIS
Reports on performance baseline metrics.

.DESCRIPTION
This script samples CPU and memory counters from local or remote computers to build a quick performance baseline.

.EXAMPLE
.\Get-PerformanceBaselineReport.ps1 -ComputerName "Server01"

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

Write-Host "Sampling performance baseline..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        $cpu = (Get-Counter -ComputerName $computer -Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 3 -ErrorAction Stop).CounterSamples | Measure-Object -Property CookedValue -Average
        $mem = (Get-Counter -ComputerName $computer -Counter '\Memory\Available MBytes' -SampleInterval 1 -MaxSamples 3 -ErrorAction Stop).CounterSamples | Measure-Object -Property CookedValue -Average
        [PSCustomObject]@{
            ComputerName   = $computer
            AvgCPUPercent  = [math]::Round($cpu.Average, 2)
            AvgAvailableMB = [math]::Round($mem.Average, 0)
            HealthStatus   = if ($cpu.Average -ge 80) { 'HIGH CPU' } elseif ($mem.Average -lt 512) { 'LOW MEMORY' } else { 'NORMAL' }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No performance baseline data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected performance baseline data for $($report.Count) computer(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
