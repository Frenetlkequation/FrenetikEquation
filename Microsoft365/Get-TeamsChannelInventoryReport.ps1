<#
.SYNOPSIS
Reports on Microsoft Teams channel inventory.

.DESCRIPTION
This script enumerates Teams channels across the tenant and reports on
membership, privacy, and archived status for governance review.

.EXAMPLE
.\Get-TeamsChannelInventoryReport.ps1

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

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Group.Read.All", "Team.ReadBasic.All" -NoWelcome

Write-Host "Retrieving Teams channel inventory..." -ForegroundColor Cyan

try {
    $teams = Get-MgTeam -All
}
catch {
    Write-Warning "Failed to retrieve Teams: $_"
    $teams = @()
}

$report = foreach ($team in $teams) {
    try {
        $channels = Get-MgTeamChannel -TeamId $team.Id -All
    }
    catch {
        Write-Warning "Failed to retrieve channels for team $($team.DisplayName): $_"
        $channels = @()
    }

    foreach ($channel in $channels) {
        [PSCustomObject]@{
            TeamName     = $team.DisplayName
            TeamId       = $team.Id
            ChannelName  = $channel.DisplayName
            ChannelId    = $channel.Id
            MembershipType = $channel.MembershipType
            Description  = $channel.Description
            IsArchived   = $channel.IsArchived
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Teams channels found." -ForegroundColor Yellow
}
else {
    $privateChannels = ($report | Where-Object { $_.MembershipType -eq "private" }).Count
    Write-Host "Retrieved $($report.Count) channel(s). Private channels: $privateChannels" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
