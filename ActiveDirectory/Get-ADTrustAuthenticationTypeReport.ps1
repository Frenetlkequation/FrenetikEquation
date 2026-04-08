<#
.SYNOPSIS
Reports on AD Authentication type.

.DESCRIPTION
This script gathers AD Authentication type data and formats a PSCustomObject report for quick review.

.EXAMPLE
.\Get-ADTrustAuthenticationTypeReport.ps1

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

#Requires -Module ActiveDirectory

Write-Host "Retrieving AD trust Authentication type report..." -ForegroundColor Cyan

try {
    $trusts = Get-ADTrust -Filter * -ErrorAction Stop | Sort-Object Name

    $report = foreach ($trust in $trusts) {
        [PSCustomObject]@{
            ReportType              = 'Authentication type'
            Name                    = $trust.Name
            Direction               = $trust.Direction
            TrustType               = $trust.TrustType
            TrustAttributes         = $trust.TrustAttributes
            Source                  = $trust.Source
            Target                  = $trust.Target
            SelectiveAuthentication = $trust.SelectiveAuthentication
            SIDFilteringForestAware = $trust.SIDFilteringForestAware
        }
    }

    if (@($report).Count -eq 0) {
        Write-Host "No trust records were returned." -ForegroundColor Yellow
    }
    else {
        Write-Host "Retrieved $(@($report).Count) trust record(s)." -ForegroundColor Green
        $report | Format-Table -AutoSize
    }
}
catch {
    Write-Host "Failed to build trust report: $($_.Exception.Message)" -ForegroundColor Red
}

