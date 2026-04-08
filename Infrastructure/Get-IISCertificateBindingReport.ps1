<#
.SYNOPSIS
Reports on IIS certificate bindings.

.DESCRIPTION
This script inventories IIS HTTPS certificate bindings for web server security review.

.EXAMPLE
.\Get-IISCertificateBindingReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module WebAdministration

Import-Module WebAdministration -ErrorAction SilentlyContinue

Write-Host "Retrieving IIS certificate bindings..." -ForegroundColor Cyan

$report = Get-WebBinding -ErrorAction SilentlyContinue | Where-Object { $_.protocol -eq 'https' } | ForEach-Object {
    [PSCustomObject]@{
        SiteName = $_.ItemXPath -replace '^.*/site\[@name=''(.*?)''\].*$', '$1'
        BindingInformation = $_.bindingInformation
        CertificateHash    = $_.certificateHash
        CertificateStore   = $_.certificateStoreName
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS certificate bindings found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS certificate binding record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
