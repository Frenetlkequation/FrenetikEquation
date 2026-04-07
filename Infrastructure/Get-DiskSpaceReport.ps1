<#
.SYNOPSIS
Checks disk space on local or remote servers.

.DESCRIPTION
This script monitors disk space usage on specified servers and reports
volumes that are below a free space threshold for proactive capacity management.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER WarningThresholdPercent
Free space percentage below which a warning is flagged. Default is 15.

.EXAMPLE
.\Get-DiskSpaceReport.ps1 -ComputerName "Server01", "Server02" -WarningThresholdPercent 20

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
    [int]$WarningThresholdPercent = 15
)

Write-Host "Checking disk space..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3" -ErrorAction Stop

        foreach ($disk in $disks) {
            $totalGB = [math]::Round($disk.Size / 1GB, 2)
            $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            $usedGB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
            $freePercent = if ($disk.Size -gt 0) { [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1) } else { 0 }

            [PSCustomObject]@{
                ComputerName = $computer
                Drive        = $disk.DeviceID
                VolumeName   = $disk.VolumeName
                TotalGB      = $totalGB
                UsedGB       = $usedGB
                FreeGB       = $freeGB
                FreePercent  = $freePercent
                Status       = if ($freePercent -lt $WarningThresholdPercent) { "WARNING" } else { "OK" }
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No disk data collected." -ForegroundColor Yellow
}
else {
    $warnings = ($report | Where-Object { $_.Status -eq "WARNING" }).Count
    Write-Host "Checked $($report.Count) volume(s). Low space warnings: $warnings" -ForegroundColor Green
    if ($warnings -gt 0) {
        Write-Host "WARNING: $warnings volume(s) below $WarningThresholdPercent% free space." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
