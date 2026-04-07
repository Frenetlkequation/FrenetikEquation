<#
.SYNOPSIS
Reports on Entra ID applications with tenant-wide admin consent grants.

.DESCRIPTION
This script retrieves delegated permission grants that have been consented for
all users in the tenant and reports the client and resource applications for
security review and application governance.

.EXAMPLE
.\Get-EntraAdminConsentAppsReport.ps1

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

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All", "DelegatedPermissionGrant.ReadWrite.All" -NoWelcome

Write-Host "Retrieving service principals and permission grants..." -ForegroundColor Cyan

$function:InvokeGraphCollection = {
    param (
        [Parameter(Mandatory)]
        [string]$Uri
    )

    $items = @()
    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType PSObject
        if ($response.value) {
            $items += $response.value
        }
        $Uri = $response.'@odata.nextLink'
    } while ($Uri)

    return $items
}

$servicePrincipals = & $function:InvokeGraphCollection "https://graph.microsoft.com/v1.0/servicePrincipals?`$select=id,appId,displayName,publisherName,servicePrincipalType"
$spLookup = @{}
foreach ($sp in $servicePrincipals) {
    $spLookup[$sp.id] = $sp
}

$grants = (& $function:InvokeGraphCollection "https://graph.microsoft.com/v1.0/oauth2PermissionGrants?`$select=id,clientId,consentType,principalId,resourceId,scope") |
    Where-Object { $_.consentType -eq "AllPrincipals" }

$report = foreach ($grant in $grants) {
    $clientSp = $spLookup[$grant.clientId]
    $resourceSp = $spLookup[$grant.resourceId]

    [PSCustomObject]@{
        ClientAppName   = if ($clientSp) { $clientSp.displayName } else { $grant.clientId }
        ClientAppId     = if ($clientSp) { $clientSp.appId } else { $null }
        ResourceAppName = if ($resourceSp) { $resourceSp.displayName } else { $grant.resourceId }
        ResourceAppId   = if ($resourceSp) { $resourceSp.appId } else { $null }
        Scope           = $grant.scope
        ConsentType     = $grant.consentType
        GrantId         = $grant.id
        PrincipalId     = $grant.principalId
    }
}

if ($report.Count -eq 0) {
    Write-Host "No tenant-wide admin consent grants found." -ForegroundColor Yellow
}
else {
    $appCount = ($report | Select-Object -ExpandProperty ClientAppName -Unique).Count
    $resourceCount = ($report | Select-Object -ExpandProperty ResourceAppName -Unique).Count

    Write-Host "Retrieved $($report.Count) admin consent grant record(s) across $appCount application(s)." -ForegroundColor Green
    Write-Host "  Resource applications: $resourceCount" -ForegroundColor Yellow
    $report | Sort-Object ClientAppName, ResourceAppName | Format-Table -AutoSize
}
