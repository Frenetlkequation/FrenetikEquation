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
