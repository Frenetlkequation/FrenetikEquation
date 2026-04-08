<#
.SYNOPSIS
Reports on NUMA configuration details.

.DESCRIPTION
This script retrieves NUMA topology information from local or remote computers for performance review.

.EXAMPLE
.\Get-NUMAConfigurationReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving NUMA configuration..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        $processors = Get-CimInstance -ClassName Win32_Processor -ComputerName $computer -ErrorAction Stop
        $logical = ($processors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
        [PSCustomObject]@{
            ComputerName = $computer
            SocketCount  = $processors.Count
            Cores        = ($processors | Measure-Object -Property NumberOfCores -Sum).Sum
            Logical      = $logical
            NumaNodes    = [math]::Max(1, [math]::Ceiling($logical / 8))
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No NUMA data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected NUMA information for $($report.Count) computer(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
