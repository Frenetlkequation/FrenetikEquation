<#
.SYNOPSIS
Reports on SharePoint Online external sharing settings.

.DESCRIPTION
This script summarizes SharePoint Online site sharing capability and helps
identify sites that permit guest or anonymous access.

.EXAMPLE
.\Get-SharePointExternalSharingReport.ps1

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

#Requires -Module Microsoft.Online.SharePoint.PowerShell

Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan

try {
    $adminUrl = Read-Host "Enter the SharePoint admin center URL"
    Connect-SPOService -Url $adminUrl
}
catch {
    Write-Warning "Failed to connect to SharePoint Online: $_"
}

Write-Host "Retrieving SharePoint sites..." -ForegroundColor Cyan

try {
    $sites = Get-SPOSite -Limit All
}
catch {
    Write-Warning "Failed to retrieve sites: $_"
    $sites = @()
}

$report = $sites | ForEach-Object {
    [PSCustomObject]@{
        Url                 = $_.Url
        Title               = $_.Title
        Template            = $_.Template
        SharingCapability    = $_.SharingCapability
        IsTeamsConnected     = $_.IsTeamsConnected
        StorageUsageCurrent  = $_.StorageUsageCurrent
    }
}

if ($report.Count -eq 0) {
    Write-Host "No SharePoint sites found." -ForegroundColor Yellow
}
else {
    $anonymous = ($report | Where-Object { $_.SharingCapability -match "Anonymous" }).Count
    $external = ($report | Where-Object { $_.SharingCapability -match "External" }).Count
    Write-Host "Retrieved $($report.Count) SharePoint site(s)." -ForegroundColor Green
    Write-Host "  Sites allowing anonymous sharing: $anonymous" -ForegroundColor Yellow
    Write-Host "  Sites allowing external sharing: $external" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
