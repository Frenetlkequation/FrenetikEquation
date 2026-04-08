<#
.SYNOPSIS
Reports on SharePoint Online external users.

.DESCRIPTION
This script inventories external users granted access to SharePoint.

.EXAMPLE
.\Get-SharePointExternalUserReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Online.SharePoint.PowerShell

Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
$adminUrl = $env:SPOTenantAdminUrl
if (-not $adminUrl) { throw "Set the SPOTenantAdminUrl environment variable to your SharePoint admin URL." }
Connect-SPOService -Url $adminUrl

Write-Host "Retrieving external users..." -ForegroundColor Cyan
$users = Get-SPOExternalUser -PageSize 200

$report = foreach ($user in $users) {
    [PSCustomObject]@{
        DisplayName = $user.DisplayName
        Email       = $user.Email
        LoginName   = $user.LoginName
        AcceptedAs  = $user.AcceptedAs
    }
}

Write-Host "Retrieved $($report.Count) external user record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
