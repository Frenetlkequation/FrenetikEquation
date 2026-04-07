<#
.SYNOPSIS
Reports on CPU utilization for local or remote computers.

.DESCRIPTION
This script retrieves CPU load information from one or more computers and
reports average utilization for capacity monitoring and troubleshooting.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-CPUUtilizationReport.ps1 -ComputerName "Server01", "Server02"

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

Write-Host "Retrieving CPU utilization..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $processors = Get-CimInstance -ClassName Win32_Processor -ComputerName $computer -ErrorAction Stop
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        $averageLoad = ($processors | Measure-Object -Property LoadPercentage -Average).Average

        [PSCustomObject]@{
            ComputerName      = $computer
            CPUName           = ($processors | Select-Object -First 1).Name
            SocketCount       = $processors.Count
            AverageLoadPercent = [math]::Round($averageLoad, 0)
            LogicalProcessors  = ($processors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
            LastBootUpTime    = $os.LastBootUpTime
            Status            = if ($averageLoad -ge 80) { "HIGH" } elseif ($averageLoad -ge 50) { "MODERATE" } else { "OK" }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No CPU data collected." -ForegroundColor Yellow
}
else {
    $high = ($report | Where-Object { $_.Status -eq "HIGH" }).Count
    Write-Host "Retrieved $($report.Count) CPU utilization record(s)." -ForegroundColor Green
    if ($high -gt 0) {
        Write-Host "  WARNING: $high computer(s) show high CPU utilization." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
