<#
.SYNOPSIS
Reports on disabled Active Directory computer and user accounts.

.DESCRIPTION
This script identifies disabled computer and user accounts in Active Directory
for cleanup planning and security auditing purposes.

.EXAMPLE
.\Get-ADDisabledAccountsReport.ps1

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

Write-Host "Retrieving disabled accounts from Active Directory..." -ForegroundColor Cyan

$disabledUsers = Get-ADUser -Filter { Enabled -eq $false } -Properties DisplayName, WhenCreated, LastLogonDate, Description, DistinguishedName |
    Select-Object SamAccountName, DisplayName, WhenCreated, LastLogonDate, Description, DistinguishedName |
    Sort-Object LastLogonDate

$disabledComputers = Get-ADComputer -Filter { Enabled -eq $false } -Properties WhenCreated, LastLogonDate, Description, OperatingSystem |
    Select-Object Name, OperatingSystem, WhenCreated, LastLogonDate, Description |
    Sort-Object LastLogonDate

Write-Host "`n--- Disabled User Accounts ---" -ForegroundColor Yellow
if ($disabledUsers.Count -eq 0) {
    Write-Host "No disabled user accounts found." -ForegroundColor Green
}
else {
    Write-Host "Found $($disabledUsers.Count) disabled user account(s)." -ForegroundColor Yellow
    $disabledUsers | Format-Table -AutoSize
}

Write-Host "`n--- Disabled Computer Accounts ---" -ForegroundColor Yellow
if ($disabledComputers.Count -eq 0) {
    Write-Host "No disabled computer accounts found." -ForegroundColor Green
}
else {
    Write-Host "Found $($disabledComputers.Count) disabled computer account(s)." -ForegroundColor Yellow
    $disabledComputers | Format-Table -AutoSize
}
