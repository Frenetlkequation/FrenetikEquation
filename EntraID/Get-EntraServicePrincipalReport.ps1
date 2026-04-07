<#
.SYNOPSIS
Reports on Entra ID service principal permissions and assignments.

.DESCRIPTION
This script retrieves service principals (enterprise applications) from Entra ID
and reports on their API permissions and app role assignments for security review.

.EXAMPLE
.\Get-EntraServicePrincipalReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Applications

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving service principals..." -ForegroundColor Cyan

$servicePrincipals = Get-MgServicePrincipal -All -Property Id, DisplayName, AppId, ServicePrincipalType, AccountEnabled, SignInAudience, AppRoles, Oauth2PermissionScopes, CreatedDateTime

$report = foreach ($sp in $servicePrincipals) {
    $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        DisplayName    = $sp.DisplayName
        AppId          = $sp.AppId
        Type           = $sp.ServicePrincipalType
        Enabled        = $sp.AccountEnabled
        SignInAudience = $sp.SignInAudience
        AppRoleCount   = if ($appRoleAssignments) { $appRoleAssignments.Count } else { 0 }
        Created        = $sp.CreatedDateTime
    }
}

if ($report.Count -eq 0) {
    Write-Host "No service principals found." -ForegroundColor Yellow
}
else {
    $disabled = ($report | Where-Object { -not $_.Enabled }).Count
    Write-Host "Retrieved $($report.Count) service principal(s). Disabled: $disabled" -ForegroundColor Green
    $report | Sort-Object DisplayName | Format-Table -AutoSize
}
