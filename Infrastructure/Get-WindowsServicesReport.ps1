<#
.SYNOPSIS
Reports on Windows services across local or remote servers.

.DESCRIPTION
This script retrieves the status of Windows services on specified servers,
identifying stopped automatic services that may need attention.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER AutomaticOnly
If specified, only reports on services set to Automatic start type.

.EXAMPLE
.\Get-WindowsServicesReport.ps1 -ComputerName "Server01" -AutomaticOnly

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
    [switch]$AutomaticOnly
)

Write-Host "Retrieving Windows services..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        $services = Get-CimInstance -ClassName Win32_Service -ComputerName $computer -ErrorAction Stop

        if ($AutomaticOnly) {
            $services = $services | Where-Object { $_.StartMode -eq "Auto" }
        }

        foreach ($svc in $services) {
            $needsAttention = ($svc.StartMode -eq "Auto" -and $svc.State -ne "Running")

            [PSCustomObject]@{
                ComputerName   = $computer
                ServiceName    = $svc.Name
                DisplayName    = $svc.DisplayName
                StartMode      = $svc.StartMode
                State          = $svc.State
                Account        = $svc.StartName
                NeedsAttention = $needsAttention
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No services found." -ForegroundColor Yellow
}
else {
    $stoppedAuto = ($report | Where-Object { $_.NeedsAttention }).Count
    Write-Host "Retrieved $($report.Count) service(s)." -ForegroundColor Green
    if ($stoppedAuto -gt 0) {
        Write-Host "WARNING: $stoppedAuto automatic service(s) are not running." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
