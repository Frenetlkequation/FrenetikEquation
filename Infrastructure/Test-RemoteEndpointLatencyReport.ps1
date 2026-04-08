<#
.SYNOPSIS
Tests latency to remote endpoints.

.DESCRIPTION
This script measures response time to one or more endpoints so you can quickly compare reachability and latency.

.EXAMPLE
.\Test-RemoteEndpointLatencyReport.ps1 -ComputerName server01,server02

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
    [string[]]$ComputerName = @($env:COMPUTERNAME),

    [Parameter()]
    [int]$Count = 4
)

Write-Host "Testing remote endpoint latency..." -ForegroundColor Cyan

try {
    $report = & {
        foreach ($computer in $ComputerName) {
                $samples = Test-Connection -ComputerName $computer -Count $Count -ErrorAction Stop
                $stats = $samples | Measure-Object -Property ResponseTime -Average -Minimum -Maximum

                [PSCustomObject]@{
                    ComputerName = $computer
                    SampleCount = $samples.Count
                    MinimumLatencyMs = [math]::Round($stats.Minimum, 2)
                    AverageLatencyMs = [math]::Round($stats.Average, 2)
                    MaximumLatencyMs = [math]::Round($stats.Maximum, 2)
                }
            }
    }
}
catch {
    Write-Warning "Failed to collect remote endpoint latency data: $_"
}

if (-not $report -or $report.Count -eq 0) {
    Write-Host "No remote endpoint latency data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected $($report.Count) remote endpoint latency record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
