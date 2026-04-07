<#
.SYNOPSIS
Reports on the top processes by memory usage.

.DESCRIPTION
This script retrieves process information from local or remote computers and
reports the highest memory consumers for troubleshooting and performance review.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER TopCount
Number of processes to return per computer. Default is 10.

.EXAMPLE
.\Get-TopProcessReport.ps1 -TopCount 15

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
    [int]$TopCount = 10
)

Write-Host "Retrieving top processes..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $processes = if ($computer -in @($env:COMPUTERNAME, 'localhost', '.')) {
            Get-Process -ErrorAction Stop
        }
        else {
            Invoke-Command -ComputerName $computer -ScriptBlock { Get-Process } -ErrorAction Stop
        }

        $processes |
            Sort-Object WorkingSet64 -Descending |
            Select-Object -First $TopCount |
            ForEach-Object {
                [PSCustomObject]@{
                    ComputerName = $computer
                    ProcessName  = $_.ProcessName
                    Id           = $_.Id
                    CPUSeconds   = if ($_.CPU) { [math]::Round([double]$_.CPU, 2) } else { 0 }
                    WorkingSetMB = [math]::Round($_.WorkingSet64 / 1MB, 2)
                    Handles      = $_.Handles
                    Status       = if ($_.WorkingSet64 / 1MB -ge 500) { "HIGH" } else { "OK" }
                }
            }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No process data collected." -ForegroundColor Yellow
}
else {
    $high = ($report | Where-Object { $_.Status -eq "HIGH" }).Count
    Write-Host "Retrieved $($report.Count) process record(s)." -ForegroundColor Green
    if ($high -gt 0) {
        Write-Host "  WARNING: $high process(es) are using large amounts of memory." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
