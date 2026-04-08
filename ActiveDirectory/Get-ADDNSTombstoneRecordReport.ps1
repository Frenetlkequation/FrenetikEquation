<#
.SYNOPSIS
Reports on AD Tombstone records.

.DESCRIPTION
This script gathers AD Tombstone records data and formats a PSCustomObject report for quick review.

.EXAMPLE
.\Get-ADDNSTombstoneRecordReport.ps1

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
#Requires -Module DnsServer

Write-Host "Retrieving DNS Tombstone records report..." -ForegroundColor Cyan

try {
    $zones = Get-DnsServerZone -ErrorAction Stop | Sort-Object ZoneName

    $report = foreach ($zone in $zones) {
        [PSCustomObject]@{
            ReportType      = 'Tombstone records'
            ZoneName        = $zone.ZoneName
            ZoneType        = $zone.ZoneType
            IsDsIntegrated  = $zone.IsDsIntegrated
            IsReverseLookup = $zone.IsReverseLookupZone
            IsAutoCreated   = $zone.IsAutoCreated
            IsSigned        = $zone.IsSigned
        }
    }

    if (@($report).Count -eq 0) {
        Write-Host "No DNS zones were returned." -ForegroundColor Yellow
    }
    else {
        Write-Host "Retrieved $(@($report).Count) DNS zone record(s)." -ForegroundColor Green
        $report | Format-Table -AutoSize
    }
}
catch {
    Write-Host "Failed to build DNS report: $($_.Exception.Message)" -ForegroundColor Red
}

