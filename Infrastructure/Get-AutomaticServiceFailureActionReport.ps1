<#
.SYNOPSIS
Reports on automatic service failure actions.

.DESCRIPTION
This script reviews Windows service recovery settings so administrators can quickly identify how failed services are configured to restart or recover.

.EXAMPLE
.\Get-AutomaticServiceFailureActionReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string[]]$ComputerName = $env:COMPUTERNAME
)

Write-Host "Retrieving service recovery settings..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    try {
        Get-CimInstance -ClassName Win32_Service -ComputerName $computer -ErrorAction Stop |
            Where-Object { $_.StartMode -ne $null } |
            Select-Object @{Name = 'ComputerName'; Expression = { $computer }}, Name, DisplayName, StartMode,
                @{Name = 'Automatic'; Expression = { $_.StartMode -eq 'Auto' }},
                State
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No service recovery data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected service recovery data for $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
