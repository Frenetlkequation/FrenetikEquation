<#
.SYNOPSIS
Reports on mailbox forwarding settings in Exchange Online.

.DESCRIPTION
This script retrieves mailbox forwarding configuration from Exchange Online
to support mail flow auditing and security review.

.PARAMETER IncludeMailboxesWithoutForwarding
Includes mailboxes that do not have forwarding configured.

.EXAMPLE
.\Get-MailboxForwardingReport.ps1

.EXAMPLE
.\Get-MailboxForwardingReport.ps1 -IncludeMailboxesWithoutForwarding

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
    [switch]$IncludeMailboxesWithoutForwarding
)

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox forwarding settings..." -ForegroundColor Cyan

$mailboxes = Get-EXOMailbox -ResultSize Unlimited -Properties RecipientTypeDetails, ForwardingSmtpAddress, ForwardingAddress, DeliverToMailboxAndForward, PrimarySmtpAddress

$report = foreach ($mailbox in $mailboxes) {
    $hasForwarding = [bool]($mailbox.ForwardingSmtpAddress -or $mailbox.ForwardingAddress)

    if ($hasForwarding -or $IncludeMailboxesWithoutForwarding.IsPresent) {
        [PSCustomObject]@{
            DisplayName                = $mailbox.DisplayName
            UserPrincipalName          = $mailbox.UserPrincipalName
            RecipientType              = $mailbox.RecipientTypeDetails
            PrimarySmtpAddress         = $mailbox.PrimarySmtpAddress
            ForwardingSmtpAddress      = if ($mailbox.ForwardingSmtpAddress) { $mailbox.ForwardingSmtpAddress } else { "None" }
            ForwardingAddress          = if ($mailbox.ForwardingAddress) { "$($mailbox.ForwardingAddress)" } else { "None" }
            DeliverToMailboxAndForward = $mailbox.DeliverToMailboxAndForward
            HasForwarding              = $hasForwarding
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mailboxes with forwarding configured were found." -ForegroundColor Yellow
}
else {
    $forwarded = ($report | Where-Object { $_.HasForwarding }).Count
    $deliverAndForward = ($report | Where-Object { $_.DeliverToMailboxAndForward }).Count

    Write-Host "Retrieved $($report.Count) mailbox forwarding record(s)." -ForegroundColor Green
    Write-Host "  Mailboxes with forwarding: $forwarded" -ForegroundColor Yellow
    Write-Host "  Deliver and forward enabled: $deliverAndForward" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
