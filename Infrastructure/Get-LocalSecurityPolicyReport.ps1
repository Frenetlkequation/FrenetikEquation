<#
.SYNOPSIS
Reports the local security policy settings.

.DESCRIPTION
This script exports the local security policy and turns the resulting sections into readable report rows.

.EXAMPLE
.\Get-LocalSecurityPolicyReport.ps1

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

Write-Host "Collecting local security policy settings..." -ForegroundColor Cyan

try {
    $report = & {
        $tempFile = Join-Path -Path $env:TEMP -ChildPath ("secpol_{0}.cfg" -f ([guid]::NewGuid().ToString('N')))

            try {
                secedit /export /cfg $tempFile /quiet | Out-Null
                $section = $null

                Get-Content -Path $tempFile -ErrorAction Stop | ForEach-Object {
                    if ($_ -match '^\[(.+)\]$') {
                        $section = $matches[1]
                        return
                    }

                    if ($_ -match '^\s*([^=]+?)\s*=\s*(.+)$') {
                        [PSCustomObject]@{
                            Section = $section
                            Setting = $matches[1].Trim()
                            Value = $matches[2].Trim()
                        }
                    }
                }
            }
            finally {
                if (Test-Path -Path $tempFile) {
                    Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
                }
            }
    }
}
catch {
    Write-Warning "Failed to collect security policy data: $_"
}

if (-not $report -or $report.Count -eq 0) {
    Write-Host "No security policy data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected $($report.Count) security policy record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
