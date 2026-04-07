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
