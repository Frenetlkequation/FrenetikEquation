<#
.SYNOPSIS
Reports on Entra ID directory roles and their members.

.DESCRIPTION
This script retrieves Entra ID directory role assignments and their members
to support privileged access review and security auditing.

.EXAMPLE
.\Get-EntraDirectoryRolesReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Identity.DirectoryManagement

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving Entra ID directory roles..." -ForegroundColor Cyan

$roles = Get-MgDirectoryRole -All

$report = foreach ($role in $roles) {
    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All

    if ($members.Count -gt 0) {
        foreach ($member in $members) {
            [PSCustomObject]@{
                RoleName        = $role.DisplayName
                RoleDescription = $role.Description
                MemberName      = $member.AdditionalProperties["displayName"]
                MemberUPN       = $member.AdditionalProperties["userPrincipalName"]
                MemberType      = $member.AdditionalProperties["@odata.type"] -replace "#microsoft.graph.", ""
                MemberId        = $member.Id
            }
        }
    }
    else {
        [PSCustomObject]@{
            RoleName        = $role.DisplayName
            RoleDescription = $role.Description
            MemberName      = "(No Members)"
            MemberUPN       = ""
            MemberType      = ""
            MemberId        = ""
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No directory roles found." -ForegroundColor Yellow
}
else {
    $globalAdmins = ($report | Where-Object { $_.RoleName -eq "Global Administrator" -and $_.MemberName -ne "(No Members)" }).Count
    Write-Host "Retrieved $($report.Count) role assignment(s) across $($roles.Count) role(s)." -ForegroundColor Green
    Write-Host "  Global Administrator members: $globalAdmins" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
