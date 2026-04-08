<#
.SYNOPSIS
Reports on Microsoft 365 sharing policy settings.

.DESCRIPTION
This script reviews SharePoint tenant sharing policy controls.

.EXAMPLE
.\Get-M365SharingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Online.SharePoint.PowerShell

Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

Write-Host "Retrieving tenant sharing settings..." -ForegroundColor Cyan
$tenant = Get-SPOTenant

$report = [PSCustomObject]@{
    SharingCapability = $tenant.SharingCapability
    DefaultSharingLinkType = $tenant.DefaultSharingLinkType
    PreventExternalUsersFromResharing = $tenant.PreventExternalUsersFromResharing
    RequireAcceptingAccountMatchInvitedAccount = $tenant.RequireAcceptingAccountMatchInvitedAccount
}

Write-Host "Retrieved sharing policy settings." -ForegroundColor Green
$report | Format-Table -AutoSize
