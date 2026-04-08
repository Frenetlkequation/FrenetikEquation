<#
.SYNOPSIS
Reports on Windows service recovery options.

.DESCRIPTION
This script inventories service recovery settings for failed-service handling review.

.EXAMPLE
.\Get-ServiceRecoveryOptionReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving service recovery options..." -ForegroundColor Cyan

$report = Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name      = $_.Name
        DisplayName = $_.DisplayName
        StartMode = $_.StartMode
        State     = $_.State
        DelayedAutoStart = $_.DelayedAutoStart
    }
}

Write-Host "Retrieved service recovery option data." -ForegroundColor Green
$report | Format-Table -AutoSize
