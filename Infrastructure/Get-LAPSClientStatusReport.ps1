<#
.SYNOPSIS
Reports the local Windows LAPS client status.

.DESCRIPTION
This script reads the local LAPS client registry state so you can review deployment and password handling details.

.EXAMPLE
.\Get-LAPSClientStatusReport.ps1

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

Write-Host "Collecting LAPS client status..." -ForegroundColor Cyan

try {
    $report = & {
        $paths = @(
                'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\LAPS'
                'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\LAPS\State'
            )

            foreach ($path in $paths) {
                if (Test-Path -Path $path) {
                    $item = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue

                    foreach ($prop in $item.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' }) {
                        [PSCustomObject]@{
                            RegistryPath = $path
                            Setting = $prop.Name
                            Value = $prop.Value
                        }
                    }
                }
            }
    }
}
catch {
    Write-Warning "Failed to collect LAPS client status data: $_"
}

if (-not $report -or $report.Count -eq 0) {
    Write-Host "No LAPS client status data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected $($report.Count) LAPS client status record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
