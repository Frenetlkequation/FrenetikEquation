<#
.SYNOPSIS
Reports on Exchange Online connectors.

.DESCRIPTION
This script retrieves inbound and outbound connectors from Exchange Online and
reports on their status, type, and TLS settings for mail flow review.

.EXAMPLE
.\Get-ExchangeConnectorReport.ps1

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

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving connectors..." -ForegroundColor Cyan

try {
    $inbound = Get-InboundConnector
    $outbound = Get-OutboundConnector
}
catch {
    Write-Warning "Failed to retrieve connectors: $_"
    $inbound = @()
    $outbound = @()
}

$report = @(
    $inbound | ForEach-Object {
        [PSCustomObject]@{
            ConnectorType      = "Inbound"
            Name               = $_.Name
            Enabled            = $_.Enabled
            ConnectorSource    = $_.ConnectorSource
            ConnectorTypeDetail = $_.ConnectorType
            TlsSettings        = $_.TlsSettings
        }
    }
    $outbound | ForEach-Object {
        [PSCustomObject]@{
            ConnectorType      = "Outbound"
            Name               = $_.Name
            Enabled            = $_.Enabled
            ConnectorSource    = $_.ConnectorSource
            ConnectorTypeDetail = $_.ConnectorType
            TlsSettings        = $_.TlsSettings
        }
    }
)

if ($report.Count -eq 0) {
    Write-Host "No connectors found." -ForegroundColor Yellow
}
else {
    $enabled = ($report | Where-Object { $_.Enabled }).Count
    Write-Host "Retrieved $($report.Count) connector(s). Enabled: $enabled" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
