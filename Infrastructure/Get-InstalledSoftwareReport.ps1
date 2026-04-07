<#
.SYNOPSIS
Reports on installed software across local or remote computers.

.DESCRIPTION
This script queries the uninstall registry keys on one or more computers and
returns installed software details for inventory and support purposes.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER NameFilter
Optional software name filter to limit results to matching products.

.EXAMPLE
.\Get-InstalledSoftwareReport.ps1 -ComputerName "Server01" -NameFilter "Microsoft"

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
param (
    [Parameter()]
    [string[]]$ComputerName = $env:COMPUTERNAME,

    [Parameter()]
    [string]$NameFilter
)

$scriptBlock = {
    param (
        [string]$FilterText
    )

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $items = foreach ($path in $paths) {
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
    }

    $items |
        Where-Object { $_.DisplayName } |
        Where-Object {
            -not $FilterText -or $_.DisplayName -like "*$FilterText*"
        } |
        ForEach-Object {
            [PSCustomObject]@{
                DisplayName        = $_.DisplayName
                DisplayVersion     = $_.DisplayVersion
                Publisher          = $_.Publisher
                InstallDate        = $_.InstallDate
                InstallLocation    = $_.InstallLocation
                EstimatedSizeMB    = if ($_.EstimatedSize) { [math]::Round($_.EstimatedSize / 1024, 2) } else { $null }
                UninstallString    = $_.UninstallString
                QuietUninstallString = $_.QuietUninstallString
            }
        } |
        Sort-Object DisplayName, DisplayVersion, Publisher -Unique
}

Write-Host "Retrieving installed software..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        if ($computer -in @($env:COMPUTERNAME, "localhost", ".")) {
            & $scriptBlock -FilterText $NameFilter |
                ForEach-Object {
                    $_ | Add-Member -NotePropertyName ComputerName -NotePropertyValue $computer -Force
                    $_
                }
        }
        else {
            Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ArgumentList $NameFilter -ErrorAction Stop |
                ForEach-Object {
                    $_ | Add-Member -NotePropertyName ComputerName -NotePropertyValue $computer -Force
                    $_
                }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No software inventory data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) software record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
