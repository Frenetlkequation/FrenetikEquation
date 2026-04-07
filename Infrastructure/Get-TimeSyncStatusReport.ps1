<#
.SYNOPSIS
Reports on time synchronization status.

.DESCRIPTION
This script queries Windows time synchronization status from local or remote
computers for troubleshooting and compliance review.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-TimeSyncStatusReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving time sync status..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $output = if ($computer -in @($env:COMPUTERNAME, 'localhost', '.')) {
            w32tm /query /status 2>$null
        }
        else {
            w32tm /query /status /computer:$computer 2>$null
        }

        if (-not $output) { continue }

        $source = ($output | Select-String '^Source:' | ForEach-Object { $_.Line.Split(':', 2)[1].Trim() }) | Select-Object -First 1
        $stratum = ($output | Select-String '^Stratum:' | ForEach-Object { $_.Line.Split(':', 2)[1].Trim() }) | Select-Object -First 1
        $lastSync = ($output | Select-String '^Last Successful Sync Time:' | ForEach-Object { $_.Line.Split(':', 2)[1].Trim() }) | Select-Object -First 1

        [PSCustomObject]@{
            ComputerName           = $computer
            Source                 = $source
            Stratum                = $stratum
            LastSuccessfulSyncTime = $lastSync
            Status                 = if ($source -and $source -ne 'Local CMOS Clock') { 'SYNCED' } else { 'CHECK' }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No time sync data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) time sync record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
