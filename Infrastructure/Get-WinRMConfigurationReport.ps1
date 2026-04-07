<#
.SYNOPSIS
Reports on WinRM configuration.

.DESCRIPTION
This script checks WinRM service configuration and basic connectivity on local
or remote computers for administration and troubleshooting.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-WinRMConfigurationReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving WinRM configuration..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $null = Test-WSMan -ComputerName $computer -ErrorAction Stop
        $config = Invoke-Command -ComputerName $computer -ScriptBlock {
            $service = Get-Item WSMan:\localhost\Service
            [PSCustomObject]@{
                ComputerName     = $env:COMPUTERNAME
                AllowUnencrypted = $service.AllowUnencrypted
                AuthBasic        = $service.Auth.Basic
                AuthKerberos     = $service.Auth.Kerberos
                AuthNegotiate    = $service.Auth.Negotiate
                IPv4Filter       = ($service.IPv4Filter -join ', ')
                IPv6Filter       = ($service.IPv6Filter -join ', ')
                WSManReachable   = $true
            }
        } -ErrorAction Stop
        $config
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
        [PSCustomObject]@{
            ComputerName     = $computer
            AllowUnencrypted = $null
            AuthBasic        = $null
            AuthKerberos     = $null
            AuthNegotiate    = $null
            IPv4Filter       = $null
            IPv6Filter       = $null
            WSManReachable   = $false
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No WinRM data collected." -ForegroundColor Yellow
}
else {
    $unreachable = ($report | Where-Object { $_.WSManReachable -eq $false }).Count
    Write-Host "Retrieved $($report.Count) WinRM configuration record(s)." -ForegroundColor Green
    if ($unreachable -gt 0) {
        Write-Host "  WARNING: $unreachable computer(s) were not reachable through WSMan." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
