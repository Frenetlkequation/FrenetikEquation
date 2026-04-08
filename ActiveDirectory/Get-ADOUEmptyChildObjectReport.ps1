<#
.SYNOPSIS
Reports on empty child objects under Active Directory organizational units.

.DESCRIPTION
This script finds OUs with little or no child activity so cleanup candidates can be reviewed.

.EXAMPLE
.[36mGet-ADOUEmptyChildObjectReport.ps1

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

$ous = Get-ADOrganizationalUnit -Filter *
$report = foreach ($ou in $ous) {
    $children = Get-ADObject -SearchBase $ou.DistinguishedName -SearchScope OneLevel -Filter * -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Name              = $ou.Name
        DistinguishedName = $ou.DistinguishedName
        ChildCount        = @($children).Count
        Empty             = @($children).Count -eq 0
    }
}

if ($report.Count -eq 0) {
    Write-Host "No data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
