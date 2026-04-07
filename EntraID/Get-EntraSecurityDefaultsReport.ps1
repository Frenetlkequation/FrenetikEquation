<#
.SYNOPSIS
Reports on Microsoft Entra security defaults.

.DESCRIPTION
This script retrieves the tenant security defaults enforcement policy and
reports whether security defaults are enabled.

.EXAMPLE
.\Get-EntraSecurityDefaultsReport.ps1

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

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

Write-Host "Retrieving security defaults policy..." -ForegroundColor Cyan
$policy = Invoke-GraphRequestJson -Uri "https://graph.microsoft.com/v1.0/policies/identitySecurityDefaultsEnforcementPolicy"

$report = [PSCustomObject]@{
    PolicyName = 'Security Defaults'
    IsEnabled  = $policy.isEnabled
}

Write-Host "Retrieved security defaults policy." -ForegroundColor Green
$report | Format-Table -AutoSize
