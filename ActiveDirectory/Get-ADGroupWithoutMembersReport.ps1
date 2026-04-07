<#
.SYNOPSIS
Reports on empty Active Directory groups.

.DESCRIPTION
This script identifies Active Directory groups without members to help
clean up stale or unused security and distribution groups.

.EXAMPLE
.\Get-ADGroupWithoutMembersReport.ps1

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

Write-Host "Searching for empty Active Directory groups..." -ForegroundColor Cyan

$groups = Get-ADGroup -Filter * -Properties Description, GroupCategory, GroupScope

$report = foreach ($group in $groups) {
    try {
        $members = @(Get-ADGroupMember -Identity $group.DistinguishedName -ErrorAction Stop)
        if ($members.Count -eq 0) {
            [PSCustomObject]@{
                Name          = $group.Name
                GroupScope    = $group.GroupScope
                GroupCategory  = $group.GroupCategory
                Description   = $group.Description
            }
        }
    }
    catch {
        Write-Warning "Failed to evaluate $($group.Name) : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No empty groups found." -ForegroundColor Green
}
else {
    Write-Host "Found $($report.Count) empty group(s)." -ForegroundColor Yellow
    $report | Sort-Object Name | Format-Table -AutoSize
}
