<#
.SYNOPSIS
Reports on a snapshot of performance counters.

.DESCRIPTION
This script captures a small set of performance counters from local or remote
computers for troubleshooting and baselining.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER Counter
One or more performance counter paths to capture. Default includes CPU, memory,
and disk counters.

.EXAMPLE
.\Get-PerformanceCounterSnapshotReport.ps1 -ComputerName "Server01"

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
    [string[]]$Counter = @(
        '\Processor(_Total)\% Processor Time',
        '\Memory\Available MBytes',
        '\LogicalDisk(_Total)\% Free Space'
    )
)

Write-Host "Capturing performance counters..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $sample = Get-Counter -ComputerName $computer -Counter $Counter -ErrorAction Stop
        foreach ($counterSample in $sample.CounterSamples) {
            [PSCustomObject]@{
                ComputerName = $computer
                CounterPath  = $counterSample.Path
                CookedValue  = [math]::Round($counterSample.CookedValue, 2)
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No performance counter data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) counter record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
