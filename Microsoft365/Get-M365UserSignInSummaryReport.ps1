<#
.SYNOPSIS
Reports on Microsoft 365 user sign-in activity.

.DESCRIPTION
This script summarizes Microsoft Entra ID sign-in logs by user for the
selected lookback window and highlights accounts with no recent activity.

.PARAMETER Days
Number of days to look back for sign-in activity. Default is 30.

.EXAMPLE
.\Get-M365UserSignInSummaryReport.ps1 -Days 30

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
    [int]$Days = 30
)

#Requires -Module Microsoft.Graph.SignIns

$cutoff = (Get-Date).ToUniversalTime().AddDays(-$Days).ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "AuditLog.Read.All" -NoWelcome

Write-Host "Retrieving sign-in logs for the last $Days day(s)..." -ForegroundColor Cyan

try {
    $signIns = Get-MgAuditLogSignIn -All -Filter "createdDateTime ge $cutoff" -Property UserPrincipalName, AppDisplayName, CreatedDateTime, Status
}
catch {
    Write-Warning "Failed to retrieve sign-in logs: $_"
    $signIns = @()
}

$report = $signIns |
    Group-Object UserPrincipalName |
    ForEach-Object {
        $items = $_.Group | Sort-Object CreatedDateTime
        [PSCustomObject]@{
            UserPrincipalName = $_.Name
            SignInCount       = $items.Count
            FirstSignIn       = ($items | Select-Object -First 1).CreatedDateTime
            LastSignIn        = ($items | Select-Object -Last 1).CreatedDateTime
            AppCount          = ($items.AppDisplayName | Sort-Object -Unique).Count
            FailedSignIns     = ($items | Where-Object { $_.Status.ErrorCode -ne 0 }).Count
        }
    } |
    Sort-Object SignInCount -Descending

if ($report.Count -eq 0) {
    Write-Host "No sign-in logs found." -ForegroundColor Yellow
}
else {
    $inactive = ($report | Where-Object { -not $_.LastSignIn }).Count
    Write-Host "Retrieved $($report.Count) user sign-in summary record(s)." -ForegroundColor Green
    Write-Host "  Users without a sign-in in the window: $inactive" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
