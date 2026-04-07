<#
.SYNOPSIS
Exports group membership information from Active Directory.

.DESCRIPTION
This script retrieves all Active Directory groups and their members,
producing a detailed membership report for auditing and documentation.

.PARAMETER GroupFilter
Optional filter to limit which groups are included. Default is all groups.

.EXAMPLE
.\Export-ADGroupMembership.ps1

.EXAMPLE
.\Export-ADGroupMembership.ps1 -GroupFilter "Domain Admins"

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
    [string]$GroupFilter = "*"
)

#Requires -Module ActiveDirectory

Write-Host "Retrieving Active Directory groups matching '$GroupFilter'..." -ForegroundColor Cyan

$groups = Get-ADGroup -Filter { Name -like $GroupFilter } -Properties Description, ManagedBy, WhenCreated

$report = foreach ($group in $groups) {
    $members = Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue

    if ($members) {
        foreach ($member in $members) {
            [PSCustomObject]@{
                GroupName        = $group.Name
                GroupCategory    = $group.GroupCategory
                GroupScope       = $group.GroupScope
                MemberName       = $member.Name
                MemberSamAccount = $member.SamAccountName
                MemberType       = $member.ObjectClass
                GroupDescription = $group.Description
            }
        }
    }
    else {
        [PSCustomObject]@{
            GroupName        = $group.Name
            GroupCategory    = $group.GroupCategory
            GroupScope       = $group.GroupScope
            MemberName       = "(No Members)"
            MemberSamAccount = ""
            MemberType       = ""
            GroupDescription = $group.Description
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No groups found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) membership record(s) across $($groups.Count) group(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
