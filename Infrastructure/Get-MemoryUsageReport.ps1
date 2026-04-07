<#
.SYNOPSIS
Reports on memory usage for local or remote computers.

.DESCRIPTION
This script retrieves physical memory usage from one or more computers for
capacity monitoring and troubleshooting.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-MemoryUsageReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving memory usage..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $usedGB = [math]::Round($totalGB - $freeGB, 2)
        $usedPercent = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100, 0) } else { 0 }

        [PSCustomObject]@{
            ComputerName = $computer
            TotalMemoryGB = $totalGB
            UsedMemoryGB  = $usedGB
            FreeMemoryGB  = $freeGB
            UsedPercent   = $usedPercent
            Status        = if ($usedPercent -ge 90) { "CRITICAL" } elseif ($usedPercent -ge 75) { "WARNING" } else { "OK" }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No memory data collected." -ForegroundColor Yellow
}
else {
    $warnings = ($report | Where-Object { $_.Status -ne "OK" }).Count
    Write-Host "Retrieved $($report.Count) memory usage record(s)." -ForegroundColor Green
    if ($warnings -gt 0) {
        Write-Host "  WARNING: $warnings computer(s) are above healthy memory thresholds." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
