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

Disclaimer:
Test this script in a non-production environment before using it in production.
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
