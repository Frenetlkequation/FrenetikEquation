<#
.SYNOPSIS
Reports on IIS bindings.

.DESCRIPTION
This script inventories IIS site bindings for web server documentation and review.

.EXAMPLE
.\Get-IISBindingReport.ps1

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

Write-Host "Retrieving IIS bindings..." -ForegroundColor Cyan

$report = Get-WebBinding -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        SiteName  = $_.ItemXPath -replace '^.*/site\[@name=''(.*?)''\].*$', '$1'
        Protocol  = $_.protocol
        BindingInformation = $_.bindingInformation
        CertificateHash = $_.certificateHash
        CertificateStoreName = $_.certificateStoreName
    }
}

if ($report.Count -eq 0) {
    Write-Host "No IIS bindings found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) IIS binding record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
