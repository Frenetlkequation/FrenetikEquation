<#
.SYNOPSIS
Reports on Microsoft Entra Connect version status.

.DESCRIPTION
This script detects the installed Microsoft Entra Connect version on the local
computer or on specified servers and compares it to the latest published
version from the official Microsoft Learn release history page.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER LatestVersionHistoryUri
The Microsoft Learn release history page used to determine the latest
published Microsoft Entra Connect version.

.EXAMPLE
.\Get-EntraConnectVersionReport.ps1

.EXAMPLE
.\Get-EntraConnectVersionReport.ps1 -ComputerName "ENTRACONNECT01"

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
    [string]$LatestVersionHistoryUri = "https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-version-history?accept=text/markdown"
)

function ConvertTo-NormalizedVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$VersionString
    )

    if (-not $VersionString) {
        return $null
    }

    $match = [regex]::Match($VersionString, "\d+\.\d+\.\d+\.\d+")
    if ($match.Success) {
        return [version]$match.Value
    }

    return $null
}

function Get-LatestEntraConnectVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Uri
    )

    $invokeParameters = @{
        Uri         = $Uri
        ErrorAction = "Stop"
    }

    if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey("UseBasicParsing")) {
        $invokeParameters.UseBasicParsing = $true
    }

    $content = (Invoke-WebRequest @invokeParameters).Content

    $versionStrings = [regex]::Matches($content, "##\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)") |
        ForEach-Object { $_.Groups[1].Value }

    if (-not $versionStrings -or $versionStrings.Count -eq 0) {
        $versionStrings = [regex]::Matches($content, "<h2[^>]*>\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\s*</h2>") |
            ForEach-Object { $_.Groups[1].Value }
    }

    if (-not $versionStrings -or $versionStrings.Count -eq 0) {
        throw "Unable to determine the latest Microsoft Entra Connect version from $Uri."
    }

    $latestVersion = $versionStrings |
        ForEach-Object { [version]$_ } |
        Sort-Object -Descending |
        Select-Object -First 1

    [PSCustomObject]@{
        LatestVersion = $latestVersion
        Source        = $Uri
        CheckedAt     = Get-Date
    }
}

function Get-InstalledEntraConnectVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TargetComputer
    )

    $scriptBlock = {
        $uninstallPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        $registryMatch = foreach ($path in $uninstallPaths) {
            Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.DisplayName -match "Entra Connect|Azure AD Connect" -and
                    $_.DisplayVersion -and
                    ([regex]::IsMatch($_.DisplayVersion, "\d+\.\d+\.\d+\.\d+"))
                }
        }

        $registryMatch = $registryMatch |
            Sort-Object { [version]([regex]::Match($_.DisplayVersion, "\d+\.\d+\.\d+\.\d+").Value) } -Descending |
            Select-Object -First 1

        if ($registryMatch) {
            return [PSCustomObject]@{
                ProductName    = $registryMatch.DisplayName
                InstalledVersion = $registryMatch.DisplayVersion
                Source         = "Registry"
            }
        }

        $candidateFiles = @(
            "C:\Program Files\Microsoft Azure Active Directory Connect\AzureADConnect.exe",
            "C:\Program Files\Microsoft Azure Active Directory Connect\Bin\miiserver.exe",
            "C:\Program Files\Microsoft Azure AD Sync\Bin\miiserver.exe"
        )

        foreach ($file in $candidateFiles) {
            if (Test-Path -LiteralPath $file) {
                $item = Get-Item -LiteralPath $file -ErrorAction Stop
                $version = if ($item.VersionInfo.ProductVersion) { $item.VersionInfo.ProductVersion } else { $item.VersionInfo.FileVersion }

                return [PSCustomObject]@{
                    ProductName      = Split-Path -Path $file -Leaf
                    InstalledVersion = $version
                    Source           = "File"
                }
            }
        }

        return $null
    }

    $localComputerNames = @(".", "localhost", $env:COMPUTERNAME)

    if ($TargetComputer -in $localComputerNames) {
        return & $scriptBlock
    }

    Invoke-Command -ComputerName $TargetComputer -ScriptBlock $scriptBlock -ErrorAction Stop
}

Write-Host "Checking Microsoft Entra Connect versions..." -ForegroundColor Cyan

$latestVersionInfo = $null
try {
    Write-Host "Retrieving the latest published Microsoft Entra Connect version..." -ForegroundColor Cyan
    $latestVersionInfo = Get-LatestEntraConnectVersion -Uri $LatestVersionHistoryUri
}
catch {
    Write-Warning "Unable to retrieve the latest Microsoft Entra Connect version: $_"
}

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $installedInfo = Get-InstalledEntraConnectVersion -TargetComputer $computer
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
        continue
    }

    if (-not $installedInfo) {
        [PSCustomObject]@{
            ComputerName     = $computer
            ProductName      = "Not Installed"
            InstalledVersion = $null
            LatestVersion    = if ($latestVersionInfo) { $latestVersionInfo.LatestVersion.ToString() } else { $null }
            IsLatest         = $false
            Status           = "Not Installed"
            DetectedFrom     = "None"
        }

        continue
    }

    $installedVersion = ConvertTo-NormalizedVersion -VersionString $installedInfo.InstalledVersion
    $latestVersion = if ($latestVersionInfo) { [version]$latestVersionInfo.LatestVersion } else { $null }

    $status = "Installed"
    $isLatest = $null

    if ($installedVersion -and $latestVersion) {
        if ($installedVersion -eq $latestVersion) {
            $status = "Latest"
            $isLatest = $true
        }
        elseif ($installedVersion -lt $latestVersion) {
            $status = "Outdated"
            $isLatest = $false
        }
        else {
            $status = "Newer Than Published Latest"
            $isLatest = $false
        }
    }
    elseif ($latestVersion) {
        $status = "Unable To Compare"
        $isLatest = $false
    }

    [PSCustomObject]@{
        ComputerName     = $computer
        ProductName      = $installedInfo.ProductName
        InstalledVersion = $installedInfo.InstalledVersion
        LatestVersion    = if ($latestVersionInfo) { $latestVersionInfo.LatestVersion.ToString() } else { $null }
        IsLatest         = $isLatest
        Status           = $status
        DetectedFrom     = $installedInfo.Source
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Microsoft Entra Connect data collected." -ForegroundColor Yellow
}
else {
    $outdated = ($report | Where-Object { $_.Status -eq "Outdated" }).Count
    $notInstalled = ($report | Where-Object { $_.Status -eq "Not Installed" }).Count

    Write-Host "Collected Microsoft Entra Connect version data for $($report.Count) computer(s)." -ForegroundColor Green
    if ($latestVersionInfo) {
        Write-Host "  Latest published version: $($latestVersionInfo.LatestVersion)" -ForegroundColor Yellow
    }
    if ($outdated -gt 0) {
        Write-Host "WARNING: $outdated computer(s) are not on the latest published version." -ForegroundColor Red
    }
    if ($notInstalled -gt 0) {
        Write-Host "  Not installed: $notInstalled" -ForegroundColor Yellow
    }
    $report | Format-Table -AutoSize
}
