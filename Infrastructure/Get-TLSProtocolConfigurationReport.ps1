<#
.SYNOPSIS
Reports TLS protocol configuration.

.DESCRIPTION
This script reads the TLS protocol registry keys and returns the configured protocol and role values.

.EXAMPLE
.\Get-TLSProtocolConfigurationReport.ps1

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

Write-Host "Collecting TLS protocol configuration..." -ForegroundColor Cyan

try {
    $report = & {
        $root = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
            $protocols = @('TLS 1.0', 'TLS 1.1', 'TLS 1.2', 'TLS 1.3')

            foreach ($protocol in $protocols) {
                $protocolPath = Join-Path -Path $root -ChildPath $protocol

                if (Test-Path -Path $protocolPath) {
                    Get-ChildItem -Path $protocolPath -ErrorAction SilentlyContinue |
                        ForEach-Object {
                            $role = Split-Path -Path $_.PSPath -Leaf
                            $item = Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue

                            foreach ($prop in $item.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' }) {
                                [PSCustomObject]@{
                                    Protocol = $protocol
                                    Role = $role
                                    Setting = $prop.Name
                                    Value = $prop.Value
                                }
                            }
                        }
                }
            }
    }
}
catch {
    Write-Warning "Failed to collect TLS protocol configuration data: $_"
}

if (-not $report -or $report.Count -eq 0) {
    Write-Host "No TLS protocol configuration data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Collected $($report.Count) TLS protocol configuration record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
