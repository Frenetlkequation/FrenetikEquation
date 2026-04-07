<#
.SYNOPSIS
Reports on OneDrive for Business sharing settings.

.DESCRIPTION
This script summarizes OneDrive site sharing capability and identifies
accounts where external or anonymous sharing is possible.

.EXAMPLE
.\Get-OneDriveSharingLinksReport.ps1

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

Write-Host "Retrieving OneDrive sites..." -ForegroundColor Cyan

try {
    $sites = Get-SPOSite -Limit All | Where-Object { $_.Url -like "*-my.sharepoint.com/personal/*" }
}
catch {
    Write-Warning "Failed to retrieve OneDrive sites: $_"
    $sites = @()
}

$report = $sites | ForEach-Object {
    [PSCustomObject]@{
        Url                = $_.Url
        Owner              = $_.Owner
        SharingCapability  = $_.SharingCapability
        StorageUsageCurrent = $_.StorageUsageCurrent
        Status             = if ($_.SharingCapability -match "Anonymous|External") { "SharingEnabled" } else { "Restricted" }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No OneDrive sites found." -ForegroundColor Yellow
}
else {
    $sharingEnabled = ($report | Where-Object { $_.Status -eq "SharingEnabled" }).Count
    Write-Host "Retrieved $($report.Count) OneDrive site(s). Sharing enabled: $sharingEnabled" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
