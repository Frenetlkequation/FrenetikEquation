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
