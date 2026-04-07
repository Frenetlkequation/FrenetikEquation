<#
.SYNOPSIS
Reports on Microsoft 365 directory role assignments.

.DESCRIPTION
This script retrieves Entra ID directory role membership and summarizes
role assignments for privileged access review.

.EXAMPLE
.\Get-M365RoleAssignmentReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied,
    including but not limited to the warranties of merchantability, fitness for a
    particular purpose, and noninfringement.

    In no event shall the authors, contributors, or copyright holders (FrenetikEquation)
    be liable for any claim, damages, or other liability, whether in an action of
    contract, tort, or otherwise, arising from, out of, or in connection with this
    script or the use or other dealings in this script. This includes, without
    limitation, any direct, indirect, incidental, special, exemplary, or consequential
    damages, including but not limited to loss of data, loss of revenue, business
    interruption, or damage to systems.

    USE AT YOUR OWN RISK. You are solely responsible for testing this script in a
    non-production environment before deploying to any production system. The user
    assumes all responsibility and risk for the use of this script. It is strongly
    recommended that you review, understand, and validate the script logic before
    execution.

    By using this script, you acknowledge and agree to these terms. If you do not
    agree, do not use this script. Refer to the LICENSE file in the root of this
    repository for the full license terms.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Identity.DirectoryManagement

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving directory roles..." -ForegroundColor Cyan

try {
    $roles = Get-MgDirectoryRole -All
}
catch {
    Write-Warning "Failed to retrieve directory roles: $_"
    $roles = @()
}

$report = foreach ($role in $roles) {
    try {
        $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All
    }
    catch {
        Write-Warning "Failed to retrieve members for role $($role.DisplayName): $_"
        $members = @()
    }

    [PSCustomObject]@{
        RoleName     = $role.DisplayName
        RoleId       = $role.Id
        MemberCount  = $members.Count
        IsPrivileged = if ($role.DisplayName -match "Admin|Administrator") { $true } else { $false }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No directory roles found." -ForegroundColor Yellow
}
else {
    $privileged = ($report | Where-Object { $_.IsPrivileged }).Count
    Write-Host "Retrieved $($report.Count) role assignment summary record(s)." -ForegroundColor Green
    Write-Host "  Privileged roles: $privileged" -ForegroundColor Yellow
    $report | Sort-Object RoleName | Format-Table -AutoSize
}
