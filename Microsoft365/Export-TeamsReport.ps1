<#
.SYNOPSIS
Exports Microsoft Teams information for reporting purposes.

.DESCRIPTION
This script retrieves Microsoft Teams data including team names, owners,
member counts, and channels for administrative reporting and governance.

.EXAMPLE
.\Export-TeamsReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Teams
#Requires -Module Microsoft.Graph.Groups

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Team.ReadBasic.All", "TeamMember.Read.All", "Channel.ReadBasic.All" -NoWelcome

Write-Host "Retrieving Microsoft Teams..." -ForegroundColor Cyan

$groups = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" -All -Property Id, DisplayName, Description, CreatedDateTime, Visibility

$report = foreach ($group in $groups) {
    $members = Get-MgGroupMember -GroupId $group.Id -All
    $owners = Get-MgGroupOwner -GroupId $group.Id -All
    $channels = Get-MgTeamChannel -TeamId $group.Id -ErrorAction SilentlyContinue

    $ownerNames = ($owners | ForEach-Object { $_.AdditionalProperties["displayName"] }) -join "; "

    [PSCustomObject]@{
        TeamName     = $group.DisplayName
        Description  = $group.Description
        Visibility   = $group.Visibility
        Owners       = if ($ownerNames) { $ownerNames } else { "None" }
        MemberCount  = $members.Count
        ChannelCount = if ($channels) { $channels.Count } else { 0 }
        Created      = $group.CreatedDateTime
    }
}

if ($report.Count -eq 0) {
    Write-Host "No teams found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) team(s)." -ForegroundColor Green
    $report | Sort-Object TeamName | Format-Table -AutoSize
}
