<#
.SYNOPSIS
Reports on Microsoft 365 admin role assignments.

.DESCRIPTION
This script inventories directory role assignments for access review.

.EXAMPLE
.\Get-M365AdminRoleAssignmentReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Identity.Governance

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving directory role assignments..." -ForegroundColor Cyan
$assignments = Get-MgRoleManagementDirectoryRoleAssignment -All -ErrorAction SilentlyContinue

$report = foreach ($assignment in $assignments) {
    [PSCustomObject]@{
        PrincipalId = $assignment.PrincipalId
        RoleDefinitionId = $assignment.RoleDefinitionId
        DirectoryScopeId = $assignment.DirectoryScopeId
    }
}

Write-Host "Retrieved $($report.Count) role assignment record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
