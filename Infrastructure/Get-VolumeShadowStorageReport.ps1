<#
.SYNOPSIS
Reports on volume shadow storage details.

.DESCRIPTION
This script retrieves shadow storage allocation information from local or remote computers.

.EXAMPLE
.\Get-VolumeShadowStorageReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving shadow storage details..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        Get-CimInstance -ClassName Win32_ShadowStorage -ComputerName $computer -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                ComputerName = $computer
                Volume       = $_.Volume
                DiffArea     = $_.DiffAreaVolume
                AllocatedGB  = [math]::Round($_.AllocatedSpace / 1GB, 2)
                UsedGB       = [math]::Round($_.UsedSpace / 1GB, 2)
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No shadow storage data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected shadow storage data for $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
