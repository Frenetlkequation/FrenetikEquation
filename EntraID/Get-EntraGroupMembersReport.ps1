<#
.SYNOPSIS
Retrieves and reports group membership information for Entra ID groups.

.DESCRIPTION
This script queries Entra ID groups and their members, producing a report
of group membership for administrative review and auditing.

.EXAMPLE
.\Get-EntraGroupMembersReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Groups

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Group.Read.All", "GroupMember.Read.All" -NoWelcome

Write-Host "Retrieving Entra ID groups..." -ForegroundColor Cyan

$groups = Get-MgGroup -All -Property Id, DisplayName, GroupTypes, SecurityEnabled, MailEnabled, MembershipRule

$report = foreach ($group in $groups) {
    $members = Get-MgGroupMember -GroupId $group.Id -All

    foreach ($member in $members) {
        [PSCustomObject]@{
            GroupName       = $group.DisplayName
            GroupId         = $group.Id
            MemberName      = $member.AdditionalProperties["displayName"]
            MemberUPN       = $member.AdditionalProperties["userPrincipalName"]
            MemberType      = $member.AdditionalProperties["@odata.type"]
            SecurityEnabled = $group.SecurityEnabled
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No group memberships found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) membership record(s) across $($groups.Count) group(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
