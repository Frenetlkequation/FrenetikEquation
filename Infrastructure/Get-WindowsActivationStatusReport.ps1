<#
.SYNOPSIS
Reports on Windows activation status.

.DESCRIPTION
This script inventories Windows activation state for the local computer.

.EXAMPLE
.\Get-WindowsActivationStatusReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving Windows activation status..." -ForegroundColor Cyan

$product = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue |
    Where-Object { $_.PartialProductKey -and $_.ApplicationId } |
    Select-Object -First 1

$report = [PSCustomObject]@{
    LicenseStatus = if ($product) { $product.LicenseStatus } else { 'Unknown' }
    PartialProductKey = if ($product) { $product.PartialProductKey } else { 'Unknown' }
    Description    = if ($product) { $product.Description } else { 'Unknown' }
}

Write-Host "Windows activation status retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
