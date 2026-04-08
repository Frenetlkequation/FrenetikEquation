<#
.SYNOPSIS
Reports on Active Directory user delegation-related flags.

.DESCRIPTION
This script summarizes delegation-capable user settings such as unconstrained delegation and sensitive-account protections.

.EXAMPLE
.[36mGet-ADUserDelegationCapabilityReport.ps1

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
    repository for the full license terms.#>

[CmdletBinding()]
param ()

#Requires -Module ActiveDirectory

Write-Host "Retrieving Active Directory report data..." -ForegroundColor Cyan

$users = Get-ADUser -Filter * -Properties TrustedForDelegation, AccountNotDelegated, SensitiveForDelegation | Sort-Object SamAccountName

$report = foreach ($user in $users) {
    [PSCustomObject]@{
        SamAccountName = $user.SamAccountName
        DisplayName    = $user.DisplayName
        TrustedForDelegation   = $user.TrustedForDelegation
        AccountNotDelegated    = $user.AccountNotDelegated
        SensitiveForDelegation = $user.SensitiveForDelegation
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
