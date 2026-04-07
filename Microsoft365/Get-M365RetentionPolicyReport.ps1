<#
.SYNOPSIS
Reports on Microsoft 365 retention policies.

.DESCRIPTION
This script retrieves retention compliance policies from the Microsoft 365
security and compliance experience for governance review.

.EXAMPLE
.\Get-M365RetentionPolicyReport.ps1

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

Write-Host "Connecting to Microsoft 365 compliance session..." -ForegroundColor Cyan
try {
    Connect-IPPSSession -ShowBanner:$false
}
catch {
    Write-Warning "Failed to connect to compliance session: $_"
}

Write-Host "Retrieving retention policies..." -ForegroundColor Cyan

try {
    $policies = Get-RetentionCompliancePolicy
}
catch {
    Write-Warning "Failed to retrieve retention policies: $_"
    $policies = @()
}

$report = $policies | ForEach-Object {
    [PSCustomObject]@{
        Name               = $_.Name
        Enabled            = $_.Enabled
        Mode               = $_.Mode
        ExchangeLocation   = $_.ExchangeLocation
        SharePointLocation = $_.SharePointLocation
        OneDriveLocation   = $_.OneDriveLocation
    }
}

if ($report.Count -eq 0) {
    Write-Host "No retention policies found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) retention policy(ies)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
