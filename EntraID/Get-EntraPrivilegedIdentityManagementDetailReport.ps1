<#
.SYNOPSIS
Reports on Entra ID privileged role schedule instances in a detail view.

.DESCRIPTION
This script queries Microsoft Graph for privileged role schedule instances and presents a detail report for governance, security, and operations review.

.EXAMPLE
.\Get-EntraPrivilegedIdentityManagementDetailReport.ps1

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
param (
    [Parameter()]
    [int]$Top = 100,

    [Parameter()]
    [int]$Days = 30
)

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "RoleManagement.Read.Directory" -NoWelcome

Write-Host "Retrieving privileged role schedule instances..." -ForegroundColor Cyan

try {
    $response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignmentScheduleInstances"
    $items = if ($response.value) { @($response.value) } else { @($response) }
}
catch {
    Write-Warning "Failed to retrieve privileged role schedule instances: $_"
    $items = @()
}
$report = foreach ($item in $items | Select-Object -First $Top) {
    [PSCustomObject]@{
        PrincipalId = $item.principalId
        RoleDefinitionId = $item.roleDefinitionId
        StartDateTime = $item.startDateTime
        EndDateTime = $item.endDateTime
    }
}

if ($report.Count -eq 0) {
    Write-Host "No privileged role schedule instances found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) privileged role schedule instances record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
