<#
.SYNOPSIS
Reports on Microsoft 365 distribution groups and their members.

.DESCRIPTION
This script retrieves distribution groups from Exchange Online and reports
on membership, owner, and configuration for administrative review and cleanup.

.EXAMPLE
.\Get-DistributionGroupReport.ps1

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

Write-Host "Retrieving distribution groups..." -ForegroundColor Cyan

$groups = Get-DistributionGroup -ResultSize Unlimited

$report = foreach ($group in $groups) {
    $members = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        DisplayName        = $group.DisplayName
        PrimarySmtpAddress = $group.PrimarySmtpAddress
        GroupType          = $group.GroupType
        ManagedBy          = ($group.ManagedBy -join "; ")
        MemberCount        = $members.Count
        HiddenFromGAL      = $group.HiddenFromAddressListsEnabled
        RequireSenderAuth  = $group.RequireSenderAuthenticationEnabled
        WhenCreated        = $group.WhenCreated
    }
}

if ($report.Count -eq 0) {
    Write-Host "No distribution groups found." -ForegroundColor Yellow
}
else {
    $emptyGroups = ($report | Where-Object { $_.MemberCount -eq 0 }).Count
    Write-Host "Retrieved $($report.Count) distribution group(s). Empty: $emptyGroups" -ForegroundColor Green
    $report | Sort-Object DisplayName | Format-Table -AutoSize
}
