<#
.SYNOPSIS
Reports on pending reboot status.

.DESCRIPTION
This script checks common Windows reboot-pending indicators on local or remote
computers for patching and maintenance planning.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-RebootPendingStatusReport.ps1 -ComputerName "Server01"

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

Write-Host "Checking pending reboot status..." -ForegroundColor Cyan

$scriptBlock = {
    $rebootRequired = $false
    $checks = @()

    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired',
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
    )

    if (Test-Path $paths[0]) { $rebootRequired = $true; $checks += 'Component Based Servicing' }
    if (Test-Path $paths[1]) { $rebootRequired = $true; $checks += 'Windows Update' }

    $sessionManager = Get-ItemProperty -Path $paths[2] -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
    if ($sessionManager.PendingFileRenameOperations) { $rebootRequired = $true; $checks += 'Pending File Rename Operations' }

    [PSCustomObject]@{
        ComputerName  = $env:COMPUTERNAME
        RebootPending = $rebootRequired
        Indicators    = if ($checks) { $checks -join ', ' } else { 'None' }
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
    Write-Host "No reboot status data collected." -ForegroundColor Yellow
}
else {
    $pending = ($report | Where-Object { $_.RebootPending -eq $true }).Count
    Write-Host "Retrieved $($report.Count) reboot status record(s)." -ForegroundColor Green
    if ($pending -gt 0) {
        Write-Host "  WARNING: $pending computer(s) have a pending reboot." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
