<#
.SYNOPSIS
Collects server inventory information for documentation and auditing.

.DESCRIPTION
This script retrieves system information from local or remote servers including
OS details, hardware specifications, and network configuration for inventory
and operational reporting.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-ServerInventory.ps1 -ComputerName "Server01", "Server02"

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

Write-Host "Collecting server inventory..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $computer -ErrorAction Stop
        $cpu = Get-CimInstance -ClassName Win32_Processor -ComputerName $computer -ErrorAction Stop | Select-Object -First 1
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3" -ErrorAction Stop

        $totalDiskGB = ($disk | Measure-Object -Property Size -Sum).Sum / 1GB
        $freeDiskGB = ($disk | Measure-Object -Property FreeSpace -Sum).Sum / 1GB

        [PSCustomObject]@{
            ComputerName   = $computer
            OSName         = $os.Caption
            OSVersion      = $os.Version
            Manufacturer   = $cs.Manufacturer
            Model          = $cs.Model
            CPUName        = $cpu.Name
            CPUCores       = $cpu.NumberOfCores
            TotalMemoryGB  = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
            TotalDiskGB    = [math]::Round($totalDiskGB, 2)
            FreeDiskGB     = [math]::Round($freeDiskGB, 2)
            LastBootTime   = $os.LastBootUpTime
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No server data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected inventory for $($report.Count) server(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
