<#
.SYNOPSIS
Reports on Entra ID application owners.

.DESCRIPTION
This script retrieves Entra ID application registrations and reports on
ownership to help identify applications without accountable owners.

.EXAMPLE
.\Get-EntraAppOwnersReport.ps1

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

#Requires -Module Microsoft.Graph.Applications

function Get-OwnerDisplayText {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object[]]$OwnerObject
    )

    if (-not $OwnerObject -or $OwnerObject.Count -eq 0) {
        return "None"
    }

    $ownerNames = foreach ($owner in $OwnerObject) {
        $displayName = $null

        if ($owner.PSObject.Properties.Name -contains "AdditionalProperties") {
            $displayName = $owner.AdditionalProperties["displayName"]
        }

        if (-not $displayName -and ($owner.PSObject.Properties.Name -contains "DisplayName")) {
            $displayName = $owner.DisplayName
        }

        if (-not $displayName) {
            $displayName = $owner.Id
        }

        $displayName
    }

    ($ownerNames | Sort-Object -Unique) -join "; "
}

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving Entra ID application registrations..." -ForegroundColor Cyan

$applications = Get-MgApplication -All -Property Id, AppId, DisplayName, CreatedDateTime | Sort-Object DisplayName

$report = foreach ($application in $applications) {
    $owners = @(Get-MgApplicationOwner -ApplicationId $application.Id -All)

    [PSCustomObject]@{
        DisplayName     = $application.DisplayName
        AppId           = $application.AppId
        CreatedDateTime = $application.CreatedDateTime
        OwnerCount      = $owners.Count
        Owners          = Get-OwnerDisplayText -OwnerObject $owners
        NoOwners        = if ($owners.Count -eq 0) { $true } else { $false }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No application registrations found." -ForegroundColor Yellow
}
else {
    $withoutOwners = ($report | Where-Object { $_.NoOwners }).Count

    Write-Host "Retrieved $($report.Count) application registration(s)." -ForegroundColor Green
    Write-Host "  Without owners: $withoutOwners" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
