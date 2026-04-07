<#
.SYNOPSIS
Reports on Microsoft 365 unified groups.

.DESCRIPTION
This script retrieves Microsoft 365 unified groups and summarizes membership
and ownership for governance review.

.EXAMPLE
.\Get-M365UnifiedGroupReport.ps1

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

Write-Host "Retrieving unified groups..." -ForegroundColor Cyan

try {
    $groups = Get-UnifiedGroup -ResultSize Unlimited
}
catch {
    Write-Warning "Failed to retrieve unified groups: $_"
    $groups = @()
}

$report = foreach ($group in $groups) {
    try {
        $owners = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Owners -ResultSize Unlimited
        $members = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -ResultSize Unlimited
    }
    catch {
        Write-Warning "Failed to retrieve links for $($group.DisplayName): $_"
        $owners = @()
        $members = @()
    }

    [PSCustomObject]@{
        DisplayName = $group.DisplayName
        PrimarySmtpAddress = $group.PrimarySmtpAddress
        AccessType  = $group.AccessType
        HiddenFromAddressListsEnabled = $group.HiddenFromAddressListsEnabled
        OwnerCount  = $owners.Count
        MemberCount = $members.Count
        WhenCreated = $group.WhenCreated
    }
}

if ($report.Count -eq 0) {
    Write-Host "No unified groups found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) unified group(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
