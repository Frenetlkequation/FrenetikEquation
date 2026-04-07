<#
.SYNOPSIS
Reports on privileged Active Directory user memberships.

.DESCRIPTION
This script retrieves members of common privileged Active Directory groups
and produces a consolidated report to support privileged access review and
security auditing.

.PARAMETER GroupName
One or more privileged group names to evaluate. Default is a curated list of
common administrative groups.

.EXAMPLE
.\Get-ADPrivilegedUsersReport.ps1

.EXAMPLE
.\Get-ADPrivilegedUsersReport.ps1 -GroupName "Domain Admins", "Enterprise Admins"

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
    [string[]]$GroupName = @(
        "Administrators",
        "Account Operators",
        "Backup Operators",
        "DnsAdmins",
        "Domain Admins",
        "Enterprise Admins",
        "Print Operators",
        "Schema Admins",
        "Server Operators"
    )
)

#Requires -Module ActiveDirectory

Write-Host "Retrieving privileged user memberships..." -ForegroundColor Cyan

$groups = foreach ($name in $GroupName) {
    try {
        Get-ADGroup -Identity $name -ErrorAction Stop
    }
    catch {
        Write-Warning "Group '$name' was not found in the current domain."
    }
}

$groups = $groups | Where-Object { $_ } | Sort-Object DistinguishedName -Unique

$memberMap = @{}

foreach ($group in $groups) {
    $members = Get-ADGroupMember -Identity $group.DistinguishedName -Recursive -ErrorAction Stop |
        Where-Object { $_.objectClass -eq "user" }

    foreach ($member in $members) {
        if (-not $memberMap.ContainsKey($member.SamAccountName)) {
            $memberMap[$member.SamAccountName] = [PSCustomObject]@{
                SamAccountName = $member.SamAccountName
                Name           = $member.Name
                MemberOf       = @()
            }
        }

        $memberMap[$member.SamAccountName].MemberOf += $group.Name
    }
}

$report = $memberMap.Values |
    Sort-Object Name |
    Select-Object SamAccountName, Name,
        @{Name = "MemberOf"; Expression = { ($_.MemberOf | Sort-Object -Unique) -join "; " }},
        @{Name = "GroupCount"; Expression = { ($_.MemberOf | Sort-Object -Unique).Count }}

if ($report.Count -eq 0) {
    Write-Host "No privileged users found." -ForegroundColor Yellow
}
else {
    $groupCount = ($groups | Measure-Object).Count

    Write-Host "Retrieved $($report.Count) privileged user(s) across $groupCount group(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
