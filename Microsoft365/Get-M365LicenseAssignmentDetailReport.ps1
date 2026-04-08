<#
.SYNOPSIS
Reports on Microsoft 365 license assignments.

.DESCRIPTION
This script inventories user license assignments across the tenant.

.EXAMPLE
.\Get-M365LicenseAssignmentDetailReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Users

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving licensed users..." -ForegroundColor Cyan
$users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses"

$report = foreach ($user in $users | Where-Object { $_.AssignedLicenses.Count -gt 0 }) {
    [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        LicenseCount      = $user.AssignedLicenses.Count
    }
}

Write-Host "Retrieved $($report.Count) licensed user record(s)." -ForegroundColor Green
$report | Sort-Object LicenseCount -Descending | Format-Table -AutoSize
