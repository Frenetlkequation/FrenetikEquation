<#
.SYNOPSIS
Reports on pending Windows updates for local or remote servers.

.DESCRIPTION
This script queries the Windows Update service for pending updates
on specified servers to support patch management and compliance auditing.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-PendingUpdatesReport.ps1 -ComputerName "Server01", "Server02"

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string[]]$ComputerName = $env:COMPUTERNAME
)

Write-Host "Checking for pending Windows updates..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session", $computer))
        $searcher = $session.CreateUpdateSearcher()
        $results = $searcher.Search("IsInstalled=0")

        foreach ($update in $results.Updates) {
            [PSCustomObject]@{
                ComputerName   = $computer
                Title          = $update.Title
                KBArticleIDs   = ($update.KBArticleIDs | ForEach-Object { "KB$_" }) -join ", "
                Severity       = $update.MsrcSeverity
                IsDownloaded   = $update.IsDownloaded
                IsMandatory    = $update.IsMandatory
                RebootRequired = $update.RebootRequired
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No pending updates found." -ForegroundColor Green
}
else {
    $critical = ($report | Where-Object { $_.Severity -eq "Critical" }).Count
    Write-Host "Found $($report.Count) pending update(s). Critical: $critical" -ForegroundColor Green
    if ($critical -gt 0) {
        Write-Host "WARNING: $critical critical update(s) pending." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
