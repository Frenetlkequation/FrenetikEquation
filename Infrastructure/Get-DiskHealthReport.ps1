<#
.SYNOPSIS
Reports on disk health details.

.DESCRIPTION
This script retrieves logical disk health information from local or remote computers for storage monitoring.

.EXAMPLE
.\Get-DiskHealthReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving disk health..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3" -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                ComputerName = $computer
                DriveLetter  = $_.DeviceID
                VolumeName   = $_.VolumeName
                FileSystem   = $_.FileSystem
                SizeGB       = [math]::Round($_.Size / 1GB, 2)
                FreeGB       = [math]::Round($_.FreeSpace / 1GB, 2)
                FreePercent  = if ($_.Size) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } else { 0 }
                Status       = if ($_.Size -and ($_.FreeSpace / $_.Size) -lt 0.15) { 'LOW' } else { 'OK' }
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
    Write-Host "Collected disk health data for $($report.Count) disk(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
