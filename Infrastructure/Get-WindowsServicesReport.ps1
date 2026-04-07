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

Disclaimer:
Test this script in a non-production environment before using it in production.
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
