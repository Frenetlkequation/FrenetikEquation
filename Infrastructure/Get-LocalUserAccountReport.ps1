<#
.SYNOPSIS
Reports on local user accounts.

.DESCRIPTION
This script retrieves local user accounts from one or more local or remote
computers for inventory, security review, and account hygiene checks.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-LocalUserAccountReport.ps1 -ComputerName "Server01", "Server02"

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

Write-Host "Retrieving local user accounts..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $users = Get-CimInstance -ClassName Win32_UserAccount -ComputerName $computer -Filter "LocalAccount=True" -ErrorAction Stop

        foreach ($user in $users) {
            [PSCustomObject]@{
                ComputerName   = $computer
                UserName       = $user.Name
                FullName       = $user.FullName
                Domain         = $user.Domain
                SID            = $user.SID
                Disabled       = $user.Disabled
                Lockout        = $user.Lockout
                PasswordChangeable = $user.PasswordChangeable
                PasswordExpires = $user.PasswordExpires
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No local user account data collected." -ForegroundColor Yellow
}
else {
    $disabled = ($report | Where-Object { $_.Disabled -eq $true }).Count
    Write-Host "Retrieved $($report.Count) local user account record(s)." -ForegroundColor Green
    if ($disabled -gt 0) {
        Write-Host "  Disabled accounts: $disabled" -ForegroundColor Yellow
    }
    $report | Format-Table -AutoSize
}
