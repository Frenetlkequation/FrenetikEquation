<#
.SYNOPSIS
Reports on mail transport rules in Exchange Online.

.DESCRIPTION
This script retrieves mail flow (transport) rules from Exchange Online and
reports on their priority, state, and conditions for governance and security review.

.EXAMPLE
.\Get-MailFlowRulesReport.ps1

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

Write-Host "Retrieving mail flow rules..." -ForegroundColor Cyan

$rules = Get-TransportRule

$report = foreach ($rule in $rules) {
    [PSCustomObject]@{
        Name              = $rule.Name
        State             = $rule.State
        Priority          = $rule.Priority
        Mode              = $rule.Mode
        SenderDomains     = ($rule.SenderDomainIs -join ", ")
        RecipientDomains  = ($rule.RecipientDomainIs -join ", ")
        FromScope         = $rule.FromScope
        SentToScope       = $rule.SentToScope
        HasExceptions     = ($null -ne $rule.ExceptIfSenderDomainIs -or $null -ne $rule.ExceptIfRecipientDomainIs)
        Comments          = $rule.Comments
        WhenChanged       = $rule.WhenChanged
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mail flow rules found." -ForegroundColor Yellow
}
else {
    $enabled = ($report | Where-Object { $_.State -eq "Enabled" }).Count
    $disabled = ($report | Where-Object { $_.State -eq "Disabled" }).Count

    Write-Host "Retrieved $($report.Count) mail flow rule(s). Enabled: $enabled, Disabled: $disabled" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
