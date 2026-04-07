<#
.SYNOPSIS
Reports on configured startup programs.

.DESCRIPTION
This script retrieves startup program entries from registry run keys on local
or remote computers for inventory and support review.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-StartupProgramReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving startup programs..." -ForegroundColor Cyan

$scriptBlock = {
    $paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            $item = Get-ItemProperty -Path $path
            foreach ($property in $item.PSObject.Properties) {
                if ($property.Name -notmatch '^PS') {
                    [PSCustomObject]@{
                        ComputerName = $env:COMPUTERNAME
                        Scope        = 'Machine'
                        Location     = $path
                        EntryName    = $property.Name
                        Command      = [string]$property.Value
                    }
                }
            }
        }
    }
}

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        if ($computer -in @($env:COMPUTERNAME, 'localhost', '.')) {
            & $scriptBlock
        }
        else {
            Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ErrorAction Stop
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No startup program data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) startup entry record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
