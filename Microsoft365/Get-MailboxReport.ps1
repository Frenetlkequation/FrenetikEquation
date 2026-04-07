<#
.SYNOPSIS
Retrieves and reports mailbox information from Exchange Online.

.DESCRIPTION
This script queries Exchange Online for mailbox data and produces a report
for administrative review and operational auditing.

.EXAMPLE
.\Get-MailboxReport.ps1

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

Write-Host "Retrieving mailbox information..." -ForegroundColor Cyan

$mailboxes = Get-EXOMailbox -ResultSize Unlimited -PropertySets All |
    Select-Object DisplayName, UserPrincipalName, PrimarySmtpAddress, RecipientTypeDetails,
        WhenCreated, IsMailboxEnabled, ArchiveStatus, RetentionPolicy

$stats = foreach ($mbx in $mailboxes) {
    $mbxStats = Get-EXOMailboxStatistics -Identity $mbx.UserPrincipalName -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        DisplayName        = $mbx.DisplayName
        UserPrincipalName  = $mbx.UserPrincipalName
        PrimarySmtpAddress = $mbx.PrimarySmtpAddress
        MailboxType        = $mbx.RecipientTypeDetails
        TotalItemSize      = $mbxStats.TotalItemSize
        ItemCount          = $mbxStats.ItemCount
        IsEnabled          = $mbx.IsMailboxEnabled
        ArchiveStatus      = $mbx.ArchiveStatus
        WhenCreated        = $mbx.WhenCreated
    }
}

if ($stats.Count -eq 0) {
    Write-Host "No mailboxes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($stats.Count) mailbox(es)." -ForegroundColor Green
    $stats | Format-Table -AutoSize
}
