<#
.SYNOPSIS
Reports on Active Directory GPO links and status.

.DESCRIPTION
This script retrieves Group Policy Objects from Active Directory and reports
on their link status, enforcement, and modification dates for GPO auditing
and documentation.

.EXAMPLE
.\Get-ADGPOReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module GroupPolicy

Write-Host "Retrieving Group Policy Objects..." -ForegroundColor Cyan

$gpos = Get-GPO -All | Sort-Object DisplayName

$report = foreach ($gpo in $gpos) {
    $gpoReport = [xml](Get-GPOReport -Guid $gpo.Id -ReportType Xml -ErrorAction SilentlyContinue)
    $links = $gpoReport.GPO.LinksTo

    [PSCustomObject]@{
        GPOName          = $gpo.DisplayName
        GPOId            = $gpo.Id
        Status           = $gpo.GpoStatus
        CreationTime     = $gpo.CreationTime
        ModificationTime = $gpo.ModificationTime
        UserVersion      = $gpo.User.DSVersion
        ComputerVersion  = $gpo.Computer.DSVersion
        LinkCount        = if ($links) { @($links).Count } else { 0 }
        LinkedTo         = if ($links) { ($links | ForEach-Object { $_.SOMPath }) -join "; " } else { "Not linked" }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No GPOs found." -ForegroundColor Yellow
}
else {
    $unlinked = ($report | Where-Object { $_.LinkCount -eq 0 }).Count
    Write-Host "Retrieved $($report.Count) GPO(s). Unlinked: $unlinked" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
