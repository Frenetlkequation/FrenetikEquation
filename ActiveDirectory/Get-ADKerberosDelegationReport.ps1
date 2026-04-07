<#
.SYNOPSIS
Reports on Kerberos delegation configuration in Active Directory.

.DESCRIPTION
This script reports on users and computers that are configured for Kerberos
delegation, including constrained and unconstrained delegation settings.

.EXAMPLE
.\Get-ADKerberosDelegationReport.ps1

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

#Requires -Module ActiveDirectory

Write-Host "Retrieving Kerberos delegation settings..." -ForegroundColor Cyan

$computers = Get-ADComputer -Filter * -Properties TrustedForDelegation, TrustedToAuthForDelegation, msDS-AllowedToDelegateTo, OperatingSystem
$users = Get-ADUser -Filter * -Properties TrustedForDelegation, TrustedToAuthForDelegation, msDS-AllowedToDelegateTo

$report = @()

foreach ($computer in $computers) {
    if ($computer.TrustedForDelegation -or $computer.TrustedToAuthForDelegation -or $computer.'msDS-AllowedToDelegateTo') {
        $report += [PSCustomObject]@{
            ObjectType      = "Computer"
            SamAccountName  = $computer.SamAccountName
            DisplayName     = $computer.Name
            DelegationType  = if ($computer.TrustedForDelegation) { "Unconstrained" } elseif ($computer.TrustedToAuthForDelegation) { "Constrained (Protocol Transition)" } else { "Constrained" }
            DelegatedTo     = if ($computer.'msDS-AllowedToDelegateTo') { $computer.'msDS-AllowedToDelegateTo' -join "; " } else { "None" }
            OperatingSystem = $computer.OperatingSystem
        }
    }
}

foreach ($user in $users) {
    if ($user.TrustedForDelegation -or $user.TrustedToAuthForDelegation -or $user.'msDS-AllowedToDelegateTo') {
        $report += [PSCustomObject]@{
            ObjectType      = "User"
            SamAccountName  = $user.SamAccountName
            DisplayName     = $user.Name
            DelegationType  = if ($user.TrustedForDelegation) { "Unconstrained" } elseif ($user.TrustedToAuthForDelegation) { "Constrained (Protocol Transition)" } else { "Constrained" }
            DelegatedTo     = if ($user.'msDS-AllowedToDelegateTo') { $user.'msDS-AllowedToDelegateTo' -join "; " } else { "None" }
            OperatingSystem = $null
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No delegation settings found." -ForegroundColor Green
}
else {
    Write-Host "Retrieved $($report.Count) delegation record(s)." -ForegroundColor Green
    $report | Sort-Object ObjectType, SamAccountName | Format-Table -AutoSize
}
