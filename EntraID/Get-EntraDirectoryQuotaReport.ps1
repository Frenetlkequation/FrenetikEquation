<#
.SYNOPSIS
Reports on Microsoft Entra directory footprint and quota-related counts.

.DESCRIPTION
This script summarizes the tenant directory footprint by counting core Entra ID
objects so administrators can review tenant scale and growth.

.EXAMPLE
.\Get-EntraDirectoryQuotaReport.ps1

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

function Get-GraphCount {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Uri)

    $response = Invoke-MgGraphRequest -Method GET -Uri $Uri -Headers @{ ConsistencyLevel = 'eventual' } -OutputType HttpResponseMessage
    $payload = $response.Content.ReadAsStringAsync().Result | ConvertFrom-Json -Depth 5
    [int]$payload.'@odata.count'
}

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Directory.Read.All" -NoWelcome

Write-Host "Retrieving directory object counts..." -ForegroundColor Cyan
$report = @(
    [PSCustomObject]@{ ObjectType = 'Users'; Count = Get-GraphCount 'https://graph.microsoft.com/v1.0/users?`$count=true&`$top=1' },
    [PSCustomObject]@{ ObjectType = 'Groups'; Count = Get-GraphCount 'https://graph.microsoft.com/v1.0/groups?`$count=true&`$top=1' },
    [PSCustomObject]@{ ObjectType = 'Applications'; Count = Get-GraphCount 'https://graph.microsoft.com/v1.0/applications?`$count=true&`$top=1' },
    [PSCustomObject]@{ ObjectType = 'ServicePrincipals'; Count = Get-GraphCount 'https://graph.microsoft.com/v1.0/servicePrincipals?`$count=true&`$top=1' },
    [PSCustomObject]@{ ObjectType = 'Devices'; Count = Get-GraphCount 'https://graph.microsoft.com/v1.0/devices?`$count=true&`$top=1' },
    [PSCustomObject]@{ ObjectType = 'Domains'; Count = Get-GraphCount 'https://graph.microsoft.com/v1.0/domains?`$count=true&`$top=1' }
)

Write-Host "Retrieved directory footprint data." -ForegroundColor Green
$report | Format-Table -AutoSize
