<#
.SYNOPSIS
Reports on Microsoft 365 mailbox archive status.

.DESCRIPTION
This script summarizes archive enablement and archive status across Exchange
Online mailboxes for retention and capacity review.

.EXAMPLE
.\Get-M365MailboxArchiveStatusReport.ps1

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

Write-Host "Retrieving mailbox archive data..." -ForegroundColor Cyan

try {
    $mailboxes = Get-EXOMailbox -ResultSize Unlimited -Properties ArchiveStatus, ArchiveName, ArchiveGuid
}
catch {
    Write-Warning "Failed to retrieve mailboxes: $_"
    $mailboxes = @()
}

$report = foreach ($mailbox in $mailboxes) {
    [PSCustomObject]@{
        DisplayName      = $mailbox.DisplayName
        UserPrincipalName = $mailbox.UserPrincipalName
        MailboxType      = $mailbox.RecipientTypeDetails
        ArchiveStatus    = $mailbox.ArchiveStatus
        ArchiveName      = $mailbox.ArchiveName
        ArchiveGuid      = $mailbox.ArchiveGuid
        ArchiveEnabled   = if ($mailbox.ArchiveStatus -and $mailbox.ArchiveStatus -ne "None") { $true } else { $false }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mailbox archive data found." -ForegroundColor Yellow
}
else {
    $archiveEnabled = ($report | Where-Object { $_.ArchiveEnabled }).Count
    Write-Host "Retrieved $($report.Count) mailbox archive record(s). Archive enabled: $archiveEnabled" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
