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
