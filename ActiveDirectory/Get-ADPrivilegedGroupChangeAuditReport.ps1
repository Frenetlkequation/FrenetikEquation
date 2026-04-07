<#
.SYNOPSIS
Reports on recent Active Directory privileged group changes.

.DESCRIPTION
This script lists privileged groups that were recently modified so recent
administrative changes can be reviewed quickly.

.PARAMETER DaysBack
Number of days back to include in the report. Default is 30.

.EXAMPLE
.\Get-ADPrivilegedGroupChangeAuditReport.ps1 -DaysBack 7

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
    [int]$DaysBack = 30
)

#Requires -Module ActiveDirectory

$cutoff = (Get-Date).AddDays(-$DaysBack)
$privilegedGroups = @("Administrators", "Domain Admins", "Enterprise Admins", "Schema Admins", "Account Operators", "Backup Operators", "Server Operators", "Print Operators")

Write-Host "Retrieving recent privileged group changes..." -ForegroundColor Cyan

$report = foreach ($name in $privilegedGroups) {
    try {
        $group = Get-ADGroup -Identity $name -Properties whenChanged, ManagedBy, GroupScope -ErrorAction Stop
        if ($group.whenChanged -ge $cutoff) {
            [PSCustomObject]@{
                Name        = $group.Name
                GroupScope  = $group.GroupScope
                WhenChanged = $group.whenChanged
                ManagedBy   = if ($group.ManagedBy) { $group.ManagedBy } else { "None" }
            }
        }
    }
    catch {
        Write-Warning "Failed to query $name : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No recent privileged group changes found." -ForegroundColor Green
}
else {
    Write-Host "Found $($report.Count) recently changed privileged group(s)." -ForegroundColor Yellow
    $report | Sort-Object WhenChanged -Descending | Format-Table -AutoSize
}
