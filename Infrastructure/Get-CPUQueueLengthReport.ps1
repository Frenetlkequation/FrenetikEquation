<#
.SYNOPSIS
Reports on CPU queue length.

.DESCRIPTION
This script samples processor queue length counters from local or remote computers for performance analysis.

.EXAMPLE
.\Get-CPUQueueLengthReport.ps1 -ComputerName "Server01"

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

Write-Host "Sampling CPU queue length..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        $sample = (Get-Counter -ComputerName $computer -Counter '\System\Processor Queue Length' -SampleInterval 1 -MaxSamples 3 -ErrorAction Stop).CounterSamples
        $average = ($sample | Measure-Object -Property CookedValue -Average).Average
        [PSCustomObject]@{
            ComputerName   = $computer
            AverageQueueLen = [math]::Round($average, 2)
            SampleCount    = @($sample).Count
            Status         = if ($average -ge 2) { 'HIGH' } elseif ($average -ge 1) { 'MODERATE' } else { 'OK' }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No CPU queue data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected CPU queue length data for $($report.Count) computer(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
