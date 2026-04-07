<#
.SYNOPSIS
Reports on Active Directory users whose department and OU do not align.

.DESCRIPTION
This script compares the Department attribute with the OU path to highlight
users whose departmental placement may need review. The match is heuristic.

.EXAMPLE
.\Get-ADUserDepartmentMismatchReport.ps1

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

Write-Host "Retrieving users for department mismatch analysis..." -ForegroundColor Cyan

$report = Get-ADUser -Filter * -Properties Department, DistinguishedName, Enabled, WhenCreated |
    ForEach-Object {
        $ou = ($_.DistinguishedName -split ",", 2)[1]
        $department = if ($_.Department) { $_.Department } else { "None" }
        $match = if ($_.Department) { $ou -match [regex]::Escape($_.Department) } else { $false }

        [PSCustomObject]@{
            SamAccountName = $_.SamAccountName
            DisplayName    = $_.DisplayName
            Department     = $department
            OU             = $ou
            Enabled        = $_.Enabled
            WhenCreated    = $_.WhenCreated
            Match          = $match
        }
    } |
    Where-Object { -not $_.Match -or $_.Department -eq "None" } |
    Sort-Object Department, SamAccountName

if ($report.Count -eq 0) {
    Write-Host "No department mismatches found." -ForegroundColor Green
}
else {
    Write-Host "Found $($report.Count) user(s) with potential department mismatches." -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
