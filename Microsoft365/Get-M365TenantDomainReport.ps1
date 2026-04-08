<#
.SYNOPSIS
Reports on Microsoft 365 tenant domains.

.DESCRIPTION
This script inventories verified domains in the tenant.

.EXAMPLE
.\Get-M365TenantDomainReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Identity.DirectoryManagement

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Domain.Read.All" -NoWelcome

Write-Host "Retrieving tenant domains..." -ForegroundColor Cyan
$domains = Get-MgDomain -All

$report = foreach ($domain in $domains) {
    [PSCustomObject]@{
        Id          = $domain.Id
        IsDefault   = $domain.IsDefault
        IsVerified  = $domain.IsVerified
        AuthenticationType = $domain.AuthenticationType
    }
}

Write-Host "Retrieved $($report.Count) tenant domain record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
