<#
.SYNOPSIS
Reports on Active Directory SIDHistory usage.

.DESCRIPTION
This script identifies users, groups, and computers with SIDHistory values
to support migrations and security review.

.EXAMPLE
.\Get-ADSIDHistoryReport.ps1

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

Write-Host "Retrieving SIDHistory data..." -ForegroundColor Cyan

$report = @()

foreach ($object in (Get-ADUser -Filter * -Properties SIDHistory)) {
    if ($object.SIDHistory) {
        $report += [PSCustomObject]@{
            ObjectType      = "User"
            SamAccountName  = $object.SamAccountName
            Name            = $object.Name
            SIDHistoryCount = @($object.SIDHistory).Count
            SIDHistory      = ($object.SIDHistory | ForEach-Object { $_.Value }) -join "; "
        }
    }
}

foreach ($object in (Get-ADGroup -Filter * -Properties SIDHistory)) {
    if ($object.SIDHistory) {
        $report += [PSCustomObject]@{
            ObjectType      = "Group"
            SamAccountName  = $object.SamAccountName
            Name            = $object.Name
            SIDHistoryCount = @($object.SIDHistory).Count
            SIDHistory      = ($object.SIDHistory | ForEach-Object { $_.Value }) -join "; "
        }
    }
}

foreach ($object in (Get-ADComputer -Filter * -Properties SIDHistory)) {
    if ($object.SIDHistory) {
        $report += [PSCustomObject]@{
            ObjectType      = "Computer"
            SamAccountName  = $object.SamAccountName
            Name            = $object.Name
            SIDHistoryCount = @($object.SIDHistory).Count
            SIDHistory      = ($object.SIDHistory | ForEach-Object { $_.Value }) -join "; "
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No SIDHistory values found." -ForegroundColor Green
}
else {
    Write-Host "Found $($report.Count) object(s) with SIDHistory." -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
