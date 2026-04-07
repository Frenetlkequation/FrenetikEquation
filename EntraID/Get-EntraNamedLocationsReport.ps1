<#
.SYNOPSIS
Reports on Microsoft Entra named locations.

.DESCRIPTION
This script retrieves Conditional Access named locations and reports trusted
status, IP ranges, and country settings for location-based policy review.

.EXAMPLE
.\Get-EntraNamedLocationsReport.ps1

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
Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

Write-Host "Retrieving named locations..." -ForegroundColor Cyan
$locations = Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations"

$report = foreach ($location in $locations) {
    $ranges = if ($location.ipRanges) { ($location.ipRanges | ForEach-Object { $_.cidrAddress }) -join '; ' } else { 'None' }
    $countries = if ($location.countriesAndRegions) { $location.countriesAndRegions -join '; ' } else { 'None' }
    [PSCustomObject]@{
        DisplayName        = $location.displayName
        Type               = $location.'@odata.type'
        IsTrusted          = $location.isTrusted
        IPRanges           = $ranges
        CountriesAndRegions = $countries
    }
}

Write-Host "Retrieved $($report.Count) named location(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
