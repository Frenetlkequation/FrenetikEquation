<#
.SYNOPSIS
Reports on Active Directory group scopes and categories.

.DESCRIPTION
This script inventories Active Directory groups and summarizes their scope,
category, and membership characteristics for review and documentation.

.EXAMPLE
.\Get-ADGroupScopeReport.ps1

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

#Requires -Module ActiveDirectory

Write-Host "Retrieving Active Directory group scope information..." -ForegroundColor Cyan

$groups = Get-ADGroup -Filter * -Properties GroupScope, GroupCategory, Members |
    Sort-Object GroupScope, Name

$report = foreach ($group in $groups) {
    [PSCustomObject]@{
        Name          = $group.Name
        GroupScope    = $group.GroupScope
        GroupCategory = $group.GroupCategory
        MemberCount   = @($group.Members).Count
    }
}

if ($report.Count -eq 0) {
    Write-Host "No groups found." -ForegroundColor Yellow
}
else {
    $domainLocal = ($report | Where-Object { $_.GroupScope -eq "DomainLocal" }).Count
    $global = ($report | Where-Object { $_.GroupScope -eq "Global" }).Count
    $universal = ($report | Where-Object { $_.GroupScope -eq "Universal" }).Count

    Write-Host "Retrieved $($report.Count) group record(s)." -ForegroundColor Green
    Write-Host "  Domain Local: $domainLocal" -ForegroundColor Yellow
    Write-Host "  Global: $global" -ForegroundColor Yellow
    Write-Host "  Universal: $universal" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
