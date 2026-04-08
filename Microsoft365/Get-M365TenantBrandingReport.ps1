<#
.SYNOPSIS
Reports on Microsoft 365 tenant branding.

.DESCRIPTION
This script inventories organization branding metadata.

.EXAMPLE
.\Get-M365TenantBrandingReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Organizations

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Organization.Read.All" -NoWelcome

Write-Host "Retrieving organization data..." -ForegroundColor Cyan
$org = Get-MgOrganization -All

$report = foreach ($item in $org) {
    [PSCustomObject]@{
        DisplayName = $item.DisplayName
        TenantId    = $item.Id
        Country     = $item.CountryLetterCode
        VerifiedDomains = ($item.VerifiedDomains.Name -join ", ")
    }
}

Write-Host "Retrieved tenant branding record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
