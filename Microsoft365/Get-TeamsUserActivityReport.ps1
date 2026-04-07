<#
.SYNOPSIS
Reports on Microsoft Teams user activity.

.DESCRIPTION
This script retrieves Teams user activity detail from Microsoft Graph and
reports on activity counts and last activity date for governance review.

.PARAMETER Period
Reporting period to query. Valid values are D7, D30, D90, and D180.

.EXAMPLE
.\Get-TeamsUserActivityReport.ps1 -Period D30

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
    [ValidateSet("D7", "D30", "D90", "D180")]
    [string]$Period = "D30"
)

#Requires -Module Microsoft.Graph.Reports

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Reports.Read.All" -NoWelcome

Write-Host "Retrieving Teams user activity data for $Period..." -ForegroundColor Cyan

$response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/reports/getTeamsUserActivityUserDetail(period='$Period')" -OutputType HttpResponseMessage
$stream = $response.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$csvContent = $reader.ReadToEnd()
$reader.Close()

$data = $csvContent | ConvertFrom-Csv

$report = foreach ($row in $data) {
    $lastActivityDate = $row.'Last Activity Date'
    $lastActivity = if ($lastActivityDate) { [datetime]$lastActivityDate } else { $null }

    [PSCustomObject]@{
        UserPrincipalName        = $row.'User Principal Name'
        DisplayName              = $row.'Display Name'
        LastActivityDate         = $lastActivityDate
        TeamChatMessageCount     = $row.'Team Chat Message Count'
        PrivateChatMessageCount  = $row.'Private Chat Message Count'
        CallCount                = $row.'Call Count'
        MeetingCount             = $row.'Meeting Count'
        IsActive                 = if ($lastActivity) { $true } else { $false }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Teams user activity data found." -ForegroundColor Yellow
}
else {
    $activeUsers = ($report | Where-Object { $_.IsActive }).Count
    $inactiveUsers = ($report | Where-Object { -not $_.IsActive }).Count

    Write-Host "Retrieved data for $($report.Count) Teams user(s)." -ForegroundColor Green
    Write-Host "  Active users: $activeUsers" -ForegroundColor Yellow
    Write-Host "  Inactive users: $inactiveUsers" -ForegroundColor Yellow
    $report | Sort-Object LastActivityDate -Descending | Format-Table -AutoSize
}
