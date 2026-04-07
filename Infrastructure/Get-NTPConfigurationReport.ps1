<#
.SYNOPSIS
Reports on NTP configuration.

.DESCRIPTION
This script retrieves Windows time service NTP configuration from local or
remote computers for troubleshooting and compliance review.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-NTPConfigurationReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving NTP configuration..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $output = if ($computer -in @($env:COMPUTERNAME, 'localhost', '.')) {
            w32tm /query /configuration 2>$null
        }
        else {
            w32tm /query /configuration /computer:$computer 2>$null
        }

        if (-not $output) { continue }

        $ntpServer = ($output | Select-String '^NtpServer:' | ForEach-Object { $_.Line.Split(':', 2)[1].Trim() }) | Select-Object -First 1
        $type = ($output | Select-String '^Type:' | ForEach-Object { $_.Line.Split(':', 2)[1].Trim() }) | Select-Object -First 1
        $specialPoll = ($output | Select-String '^SpecialPollInterval:' | ForEach-Object { $_.Line.Split(':', 2)[1].Trim() }) | Select-Object -First 1

        [PSCustomObject]@{
            ComputerName        = $computer
            NtpServer           = $ntpServer
            Type                = $type
            SpecialPollInterval = $specialPoll
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No NTP configuration data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) NTP configuration record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
