<#
.SYNOPSIS
Reports on shared mailboxes in Exchange Online.

.DESCRIPTION
This script retrieves shared mailbox information including size, permissions,
and forwarding status for administrative review and auditing.

.EXAMPLE
.\Get-SharedMailboxReport.ps1

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

Write-Host "Retrieving shared mailboxes..." -ForegroundColor Cyan

$sharedMailboxes = Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited

$report = foreach ($mbx in $sharedMailboxes) {
    $stats = Get-EXOMailboxStatistics -Identity $mbx.UserPrincipalName -ErrorAction SilentlyContinue
    $permissions = Get-EXOMailboxPermission -Identity $mbx.UserPrincipalName |
        Where-Object { $_.User -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false }

    $delegateList = ($permissions | ForEach-Object { $_.User }) -join "; "

    [PSCustomObject]@{
        DisplayName        = $mbx.DisplayName
        PrimarySmtpAddress = $mbx.PrimarySmtpAddress
        TotalItemSize      = $stats.TotalItemSize
        ItemCount          = $stats.ItemCount
        Delegates          = if ($delegateList) { $delegateList } else { "None" }
        ForwardingAddress  = $mbx.ForwardingSmtpAddress
        WhenCreated        = $mbx.WhenCreated
    }
}

if ($report.Count -eq 0) {
    Write-Host "No shared mailboxes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) shared mailbox(es)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
