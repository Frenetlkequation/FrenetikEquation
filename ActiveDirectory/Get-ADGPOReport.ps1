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
