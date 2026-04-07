<#
.SYNOPSIS
Reports on privileged Entra ID role assignments.

.DESCRIPTION
This script retrieves directory role assignments from Microsoft Entra ID and
reports the principal, role definition, and scope for privileged access review.

.EXAMPLE
.\Get-EntraPrivilegedRoleAssignmentsReport.ps1

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

#Requires -Module Microsoft.Graph.Authentication

function Invoke-GraphRequestJson {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Uri)

    $response = Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType HttpResponseMessage
    $content = $response.Content.ReadAsStringAsync().Result
    if ([string]::IsNullOrWhiteSpace($content)) { return $null }
    $content | ConvertFrom-Json -Depth 20
}

function Get-GraphCollection {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Uri)

    $items = @()
    do {
        $payload = Invoke-GraphRequestJson -Uri $Uri
        if ($null -ne $payload.value) { $items += @($payload.value) } elseif ($null -ne $payload) { $items += @($payload) }
        $Uri = $payload.'@odata.nextLink'
    } while ($Uri)
    $items
}

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving privileged role assignments..." -ForegroundColor Cyan
$report = Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$expand=principal,roleDefinition&`$select=id,principalId,roleDefinitionId,directoryScopeId" |
    ForEach-Object {
        $principal = if ($_.principal.displayName) { $_.principal.displayName } else { $_.principalId }
        $role = if ($_.roleDefinition.displayName) { $_.roleDefinition.displayName } else { $_.roleDefinitionId }
        [PSCustomObject]@{
            AssignmentId    = $_.id
            Principal       = $principal
            RoleDefinition  = $role
            DirectoryScopeId = $_.directoryScopeId
        }
    }

if ($report.Count -eq 0) {
    Write-Host "No privileged role assignments found." -ForegroundColor Green
}
else {
    $roleCount = ($report | Select-Object -ExpandProperty RoleDefinition -Unique).Count
    Write-Host "Found $($report.Count) privileged role assignment(s) across $roleCount role(s)." -ForegroundColor Yellow
    $report | Sort-Object RoleDefinition, Principal | Format-Table -AutoSize
}
