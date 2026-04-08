<#
.SYNOPSIS
Reports on system thermal sensor details.

.DESCRIPTION
This script retrieves thermal sensor readings from local or remote computers for hardware monitoring.

.EXAMPLE
.\Get-SystemThermalSensorReport.ps1 -ComputerName "Server01"

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

    USE YOUR OWN RISK. You are solely responsible for testing this script in a
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

Write-Host "Retrieving thermal sensor data..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ComputerName $computer -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                ComputerName = $computer
                InstanceName = $_.InstanceName
                TemperatureC = [math]::Round(($_.CurrentTemperature / 10) - 273.15, 2)
                ThermalState = $_.Active
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No thermal sensor data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected thermal sensor data for $($report.Count) sensor record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
