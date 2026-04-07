<#
.SYNOPSIS
Reports on nested Active Directory group membership.

.DESCRIPTION
This script expands group membership recursively for a curated set of Active
Directory groups and identifies nested groups and leaf members.

.PARAMETER GroupName
One or more group names to inspect. Default is a common privileged group set.

.EXAMPLE
.\Get-ADNestedGroupMembershipReport.ps1 -GroupName "Domain Admins"

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
    [string[]]$GroupName = @("Administrators", "Domain Admins", "Enterprise Admins", "Schema Admins")
)

#Requires -Module ActiveDirectory

Write-Host "Retrieving nested group membership..." -ForegroundColor Cyan

$report = foreach ($name in $GroupName) {
    try {
        $group = Get-ADGroup -Identity $name -ErrorAction Stop
        $members = Get-ADGroupMember -Identity $group.DistinguishedName -Recursive -ErrorAction Stop

        if (-not $members) {
            [PSCustomObject]@{
                GroupName     = $group.Name
                MemberName    = "No members"
                ObjectClass    = "None"
                IsNestedGroup = $false
            }
        }
        else {
            foreach ($member in $members) {
                [PSCustomObject]@{
                    GroupName     = $group.Name
                    MemberName    = $member.Name
                    ObjectClass   = $member.ObjectClass
                    IsNestedGroup = $member.ObjectClass -eq "group"
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to process $name : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No nested membership data collected." -ForegroundColor Yellow
}
else {
    $nested = ($report | Where-Object { $_.IsNestedGroup }).Count
    Write-Host "Retrieved $($report.Count) membership record(s). Nested groups: $nested" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
