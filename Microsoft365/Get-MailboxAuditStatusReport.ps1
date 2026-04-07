<#
.SYNOPSIS
Reports on Exchange Online mailbox audit status.

.DESCRIPTION
This script checks mailbox audit settings in Exchange Online and identifies
mailboxes with auditing disabled or missing audit retention details.

.EXAMPLE
.\Get-MailboxAuditStatusReport.ps1

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

Write-Host "Retrieving mailbox audit settings..." -ForegroundColor Cyan

$mailboxes = Get-EXOMailbox -ResultSize Unlimited -Properties AuditEnabled,AuditLogAgeLimit,PrimarySmtpAddress,WhenCreated,RecipientTypeDetails

$report = foreach ($mbx in $mailboxes) {
    [PSCustomObject]@{
        DisplayName        = $mbx.DisplayName
        UserPrincipalName  = $mbx.UserPrincipalName
        RecipientType      = $mbx.RecipientTypeDetails
        PrimarySmtpAddress = $mbx.PrimarySmtpAddress
        AuditEnabled       = $mbx.AuditEnabled
        AuditLogAgeLimit   = $mbx.AuditLogAgeLimit
        WhenCreated        = $mbx.WhenCreated
        Status             = if ($mbx.AuditEnabled) { "Enabled" } else { "Disabled" }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mailbox audit data found." -ForegroundColor Yellow
}
else {
    $disabled = ($report | Where-Object { -not $_.AuditEnabled }).Count

    Write-Host "Retrieved $($report.Count) mailbox record(s)." -ForegroundColor Green
    Write-Host "  Mailboxes with audit disabled: $disabled" -ForegroundColor Yellow
    if ($disabled -gt 0) {
        Write-Host "WARNING: Some mailboxes do not have auditing enabled." -ForegroundColor Red
    }
    $report | Sort-Object Status, DisplayName | Format-Table -AutoSize
}
