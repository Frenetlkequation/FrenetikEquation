<#
.SYNOPSIS
Reports on local Administrators group membership.

.DESCRIPTION
This script retrieves members of the local Administrators group on one or more
local or remote computers for privilege review and workstation/server auditing.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-LocalAdministratorsReport.ps1 -ComputerName "Server01", "Server02"

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
    [string[]]$ComputerName = $env:COMPUTERNAME
)

Write-Host "Retrieving local Administrators group membership..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $members = Get-CimInstance -ComputerName $computer -Query "ASSOCIATORS OF {Win32_Group.SID='S-1-5-32-544'} WHERE AssocClass=Win32_GroupUser Role=Group" -ErrorAction Stop

        foreach ($member in $members) {
            [PSCustomObject]@{
                ComputerName   = $computer
                MemberName     = $member.Name
                Domain         = $member.Domain
                SID            = $member.SID
                LocalAccount   = $member.LocalAccount
                Disabled       = $member.Disabled
                ObjectClass    = $member.CimClass.CimClassName
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No local Administrator membership data collected." -ForegroundColor Yellow
}
else {
    $disabled = ($report | Where-Object { $_.Disabled -eq $true }).Count
    Write-Host "Retrieved $($report.Count) membership record(s)." -ForegroundColor Green
    if ($disabled -gt 0) {
        Write-Host "  Disabled accounts: $disabled" -ForegroundColor Yellow
    }
    $report | Format-Table -AutoSize
}
