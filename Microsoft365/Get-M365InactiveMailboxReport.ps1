<#
.SYNOPSIS
Reports on inactive Exchange Online mailboxes.

.DESCRIPTION
This script identifies mailboxes that have not logged on within the selected
window to support cleanup and retention reviews.

.PARAMETER DaysInactive
Number of days since last logon before a mailbox is considered inactive.

.EXAMPLE
.\Get-M365InactiveMailboxReport.ps1 -DaysInactive 90

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
    [int]$DaysInactive = 90
)

#Requires -Module ExchangeOnlineManagement

$cutoff = (Get-Date).AddDays(-$DaysInactive)

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox activity data..." -ForegroundColor Cyan

try {
    $mailboxes = Get-EXOMailbox -ResultSize Unlimited -Properties UserPrincipalName, DisplayName, RecipientTypeDetails, ArchiveStatus
}
catch {
    Write-Warning "Failed to retrieve mailboxes: $_"
    $mailboxes = @()
}

$report = foreach ($mailbox in $mailboxes) {
    try {
        $stats = Get-EXOMailboxStatistics -Identity $mailbox.UserPrincipalName -ErrorAction SilentlyContinue
        $lastLogon = $stats.LastLogonTime
    }
    catch {
        $lastLogon = $null
    }

    if (-not $lastLogon -or $lastLogon -lt $cutoff) {
        [PSCustomObject]@{
            DisplayName    = $mailbox.DisplayName
            UserPrincipalName = $mailbox.UserPrincipalName
            MailboxType    = $mailbox.RecipientTypeDetails
            LastLogonTime  = $lastLogon
            DaysSinceLogon = if ($lastLogon) { [math]::Round(((Get-Date) - $lastLogon).TotalDays, 0) } else { "Never" }
            ArchiveStatus  = $mailbox.ArchiveStatus
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No inactive mailboxes found." -ForegroundColor Green
}
else {
    Write-Host "Found $($report.Count) inactive mailbox(es)." -ForegroundColor Yellow
    $report | Sort-Object DaysSinceLogon -Descending | Format-Table -AutoSize
}
