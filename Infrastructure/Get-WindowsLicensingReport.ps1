<#
.SYNOPSIS
Reports on Windows licensing details.

.DESCRIPTION
This script inventories Windows licensing information for the local computer.

.EXAMPLE
.\Get-WindowsLicensingReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving Windows licensing details..." -ForegroundColor Cyan

$service = Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction SilentlyContinue
$product = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue |
    Where-Object { $_.PartialProductKey -and $_.LicenseStatus -ne $null } | Select-Object -First 1

$report = [PSCustomObject]@{
    OA3xOriginalProductKey = if ($service) { $service.OA3xOriginalProductKey } else { 'Unknown' }
    LicenseStatus          = if ($product) { $product.LicenseStatus } else { 'Unknown' }
    GracePeriodRemaining   = if ($product) { $product.GracePeriodRemaining } else { 'Unknown' }
}

Write-Host "Windows licensing details retrieved." -ForegroundColor Green
$report | Format-Table -AutoSize
