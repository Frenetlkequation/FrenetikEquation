<#
.SYNOPSIS
Reports on duplicate Service Principal Names in Active Directory.

.DESCRIPTION
This script searches Active Directory objects with service principal names
and identifies duplicate SPNs that can cause Kerberos authentication issues.

.EXAMPLE
.\Get-ADDuplicateSPNReport.ps1

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

Write-Host "Searching for duplicate SPNs..." -ForegroundColor Cyan

$spnObjects = Get-ADObject -LDAPFilter "(servicePrincipalName=*)" -Properties servicePrincipalName, objectClass, samAccountName, distinguishedName

$duplicates = $spnObjects |
    ForEach-Object {
        foreach ($spn in $_.servicePrincipalName) {
            [PSCustomObject]@{
                ServicePrincipalName = $spn
                SamAccountName       = $_.SamAccountName
                ObjectClass          = $_.ObjectClass
                DistinguishedName    = $_.DistinguishedName
            }
        }
    } |
    Group-Object ServicePrincipalName |
    Where-Object { $_.Count -gt 1 }

$report = foreach ($item in $duplicates) {
    foreach ($entry in $item.Group) {
        [PSCustomObject]@{
            ServicePrincipalName = $entry.ServicePrincipalName
            SamAccountName       = $entry.SamAccountName
            ObjectClass          = $entry.ObjectClass
            DistinguishedName    = $entry.DistinguishedName
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No duplicate SPNs found." -ForegroundColor Green
}
else {
    Write-Host "Found $($report.Count) duplicate SPN record(s)." -ForegroundColor Yellow
    $report | Sort-Object ServicePrincipalName, SamAccountName | Format-Table -AutoSize
}
