<#
.SYNOPSIS
Reports on Exchange Online organization relationships.

.DESCRIPTION
This script inventories hybrid and cross-tenant organization relationships.

.EXAMPLE
.\Get-ExchangeOrganizationRelationshipReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving organization relationships..." -ForegroundColor Cyan
$relationships = Get-OrganizationRelationship

$report = foreach ($relationship in $relationships) {
    [PSCustomObject]@{
        Name                    = $relationship.Name
        DomainNames             = ($relationship.DomainNames -join ", ")
        Enabled                 = $relationship.Enabled
        FreeBusyAccessEnabled   = $relationship.FreeBusyAccessEnabled
        MailboxMoveEnabled      = $relationship.MailboxMoveEnabled
        ArchiveAccessEnabled    = $relationship.ArchiveAccessEnabled
    }
}

if ($report.Count -eq 0) {
    Write-Host "No organization relationships found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) organization relationship(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
