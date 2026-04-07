<#
.SYNOPSIS
Reports on local group membership.

.DESCRIPTION
This script retrieves members of a specified local group from local or remote
computers for access review and administration.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER GroupName
Local group name to query. Default is Administrators.

.EXAMPLE
.\Get-LocalGroupMembershipReport.ps1 -GroupName "Remote Desktop Users"

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
    [string[]]$ComputerName = $env:COMPUTERNAME,

    [Parameter()]
    [string]$GroupName = 'Administrators'
)

Write-Host "Retrieving local group membership..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $group = Get-CimInstance -ClassName Win32_Group -ComputerName $computer -Filter "LocalAccount=True AND Name='$GroupName'" -ErrorAction Stop | Select-Object -First 1
        if (-not $group) {
            Write-Warning "Group '$GroupName' not found on $computer."
            continue
        }

        $members = Get-CimInstance -ComputerName $computer -Query "ASSOCIATORS OF {Win32_Group.Domain='$computer',Name='$GroupName'} WHERE AssocClass=Win32_GroupUser Role=Group" -ErrorAction Stop

        foreach ($member in $members) {
            [PSCustomObject]@{
                ComputerName = $computer
                GroupName    = $GroupName
                MemberName   = $member.Name
                Domain       = $member.Domain
                SID          = $member.SID
                LocalAccount = $member.LocalAccount
                Disabled     = $member.Disabled
                ObjectClass  = $member.CimClass.CimClassName
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No local group membership data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) membership record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
