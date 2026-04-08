<#
.SYNOPSIS
Reports PowerShell profile configuration.

.DESCRIPTION
This script lists the standard PowerShell profile paths and whether each one exists on the local machine.

.EXAMPLE
.\Get-PowerShellProfileConfigurationReport.ps1

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

Write-Host "Collecting PowerShell profile configuration..." -ForegroundColor Cyan

try {
    $report = & {
        $profiles = @(
                [PSCustomObject]@{ Scope = 'CurrentUserCurrentHost'; Path = $PROFILE.CurrentUserCurrentHost },
                [PSCustomObject]@{ Scope = 'CurrentUserAllHosts'; Path = $PROFILE.CurrentUserAllHosts },
                [PSCustomObject]@{ Scope = 'AllUsersCurrentHost'; Path = $PROFILE.AllUsersCurrentHost },
                [PSCustomObject]@{ Scope = 'AllUsersAllHosts'; Path = $PROFILE.AllUsersAllHosts }
            )

            foreach ($profile in $profiles) {
                $exists = Test-Path -Path $profile.Path
                $length = if ($exists) { (Get-Item -Path $profile.Path).Length } else { 0 }

                [PSCustomObject]@{
                    Scope = $profile.Scope
                    Path = $profile.Path
                    Exists = $exists
                    LengthBytes = $length
                }
            }
    }
}
catch {
    Write-Warning "Failed to collect PowerShell profile data: $_"
}

if (-not $report -or $report.Count -eq 0) {
    Write-Host "No PowerShell profile data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected $($report.Count) PowerShell profile record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
