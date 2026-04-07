<#
.SYNOPSIS
Exports Entra ID sign-in activity report.

.DESCRIPTION
This script retrieves recent sign-in logs from Entra ID for security monitoring,
user activity review, and compliance auditing.

.PARAMETER Days
Number of days of sign-in history to retrieve. Default is 7.

.EXAMPLE
.\Get-EntraSignInReport.ps1 -Days 30

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
    [int]$Days = 7
)

#Requires -Module Microsoft.Graph.Reports

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "AuditLog.Read.All", "Directory.Read.All" -NoWelcome

$startDate = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "Retrieving sign-in logs from the last $Days day(s)..." -ForegroundColor Cyan

$signIns = Get-MgAuditLogSignIn -Filter "createdDateTime ge $startDate" -All |
    Select-Object UserDisplayName, UserPrincipalName, AppDisplayName, IpAddress,
        @{Name = "Location"; Expression = { "$($_.Location.City), $($_.Location.CountryOrRegion)" }},
        @{Name = "Status"; Expression = { if ($_.Status.ErrorCode -eq 0) { "Success" } else { "Failed" } }},
        @{Name = "ErrorCode"; Expression = { $_.Status.ErrorCode }},
        @{Name = "FailureReason"; Expression = { $_.Status.FailureReason }},
        CreatedDateTime,
        ConditionalAccessStatus |
    Sort-Object CreatedDateTime -Descending

if ($signIns.Count -eq 0) {
    Write-Host "No sign-in logs found." -ForegroundColor Yellow
}
else {
    $failed = ($signIns | Where-Object { $_.Status -eq "Failed" }).Count
    Write-Host "Retrieved $($signIns.Count) sign-in record(s). Failed: $failed" -ForegroundColor Green
    $signIns | Format-Table -AutoSize
}
