<#
.SYNOPSIS
Reports on Active Directory Windows LAPS password rotation status.

.DESCRIPTION
This script checks whether the Windows LAPS schema extension is present and
inventories computer accounts for Windows LAPS password expiration timestamps.
It also flags legacy LAPS timestamps to help with migration and operational
review.

.PARAMETER ExpiringWithinDays
Number of days ahead to flag Windows LAPS passwords as expiring soon. Default is 7.

.PARAMETER SearchBase
Optional distinguished name to scope the computer search to a specific OU or container.

.EXAMPLE
.\Get-ADWindowsLAPSStatusReport.ps1 -ExpiringWithinDays 14

.EXAMPLE
.\Get-ADWindowsLAPSStatusReport.ps1 -SearchBase "OU=Servers,DC=contoso,DC=com"

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
    [int]$ExpiringWithinDays = 7,

    [Parameter()]
    [string]$SearchBase
)

#Requires -Module ActiveDirectory

function Convert-ADFileTimeToUtc {
    [CmdletBinding()]
    param (
        [Parameter()]
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return $null
    }

    try {
        $fileTime = [int64]$Value
    }
    catch {
        return $null
    }

    if ($fileTime -le 0) {
        return $null
    }

    [datetime]::FromFileTimeUtc($fileTime)
}

function Test-ADSchemaAttribute {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$SchemaNamingContext,

        [Parameter(Mandatory)]
        [string]$LdapDisplayName
    )

    $attribute = Get-ADObject -SearchBase $SchemaNamingContext -LDAPFilter "(lDAPDisplayName=$LdapDisplayName)" -ErrorAction SilentlyContinue
    $null -ne $attribute
}

$nowUtc = (Get-Date).ToUniversalTime()
$thresholdUtc = $nowUtc.AddDays($ExpiringWithinDays)

Write-Host "Inspecting Active Directory schema for LAPS attributes..." -ForegroundColor Cyan

$rootDse = Get-ADRootDSE
$schemaNamingContext = $rootDse.SchemaNamingContext
$windowsLapsSchemaPresent = Test-ADSchemaAttribute -SchemaNamingContext $schemaNamingContext -LdapDisplayName "msLAPS-PasswordExpirationTime"
$legacyLapsSchemaPresent = Test-ADSchemaAttribute -SchemaNamingContext $schemaNamingContext -LdapDisplayName "ms-Mcs-AdmPwdExpirationTime"

if ($windowsLapsSchemaPresent) {
    Write-Host "Windows LAPS schema attribute msLAPS-PasswordExpirationTime detected." -ForegroundColor Green
}
else {
    Write-Host "Windows LAPS schema attribute msLAPS-PasswordExpirationTime was not found." -ForegroundColor Yellow
}

Write-Host "Retrieving Active Directory computer accounts for Windows LAPS review..." -ForegroundColor Cyan

$properties = @("Enabled", "OperatingSystem", "LastLogonDate")
if ($windowsLapsSchemaPresent) {
    $properties += "msLAPS-PasswordExpirationTime"
}

if ($legacyLapsSchemaPresent) {
    $properties += "ms-Mcs-AdmPwdExpirationTime"
}

$computerParams = @{
    Filter     = "*"
    Properties = $properties
}

if ($SearchBase) {
    $computerParams.SearchBase = $SearchBase
}

$computers = Get-ADComputer @computerParams | Sort-Object Name

$report = foreach ($computer in $computers) {
    $windowsLapsExpiryUtc = if ($windowsLapsSchemaPresent) {
        Convert-ADFileTimeToUtc -Value $computer."msLAPS-PasswordExpirationTime"
    }
    else {
        $null
    }

    $legacyLapsExpiryUtc = if ($legacyLapsSchemaPresent) {
        Convert-ADFileTimeToUtc -Value $computer."ms-Mcs-AdmPwdExpirationTime"
    }
    else {
        $null
    }

    $windowsLapsManaged = $null -ne $windowsLapsExpiryUtc
    $legacyLapsManaged = $null -ne $legacyLapsExpiryUtc

    $lapsMode = if ($windowsLapsManaged -and $legacyLapsManaged) {
        "Windows and Legacy"
    }
    elseif ($windowsLapsManaged) {
        "Windows LAPS"
    }
    elseif ($legacyLapsManaged) {
        "Legacy LAPS"
    }
    else {
        "Not Configured"
    }

    $rotationStatus = if (-not $windowsLapsSchemaPresent) {
        if ($legacyLapsManaged) { "Legacy Only" } else { "Schema Missing" }
    }
    elseif (-not $windowsLapsManaged) {
        if ($legacyLapsManaged) { "Legacy Only" } else { "Not Configured" }
    }
    elseif ($windowsLapsExpiryUtc -lt $nowUtc) {
        "Expired"
    }
    elseif ($windowsLapsExpiryUtc -lt $thresholdUtc) {
        "Expiring Soon"
    }
    else {
        "Scheduled"
    }

    [PSCustomObject]@{
        Name                         = $computer.Name
        Enabled                      = $computer.Enabled
        OperatingSystem              = $computer.OperatingSystem
        LAPSMode                     = $lapsMode
        RotationStatus               = $rotationStatus
        WindowsLAPSManaged           = $windowsLapsManaged
        WindowsLAPSPasswordExpiryUtc = $windowsLapsExpiryUtc
        DaysUntilWindowsLAPSExpiry   = if ($windowsLapsExpiryUtc) { [math]::Round(($windowsLapsExpiryUtc - $nowUtc).TotalDays, 0) } else { $null }
        LegacyLAPSManaged            = $legacyLapsManaged
        LegacyLAPSPasswordExpiryUtc  = $legacyLapsExpiryUtc
        LastLogonDate                = $computer.LastLogonDate
        DistinguishedName            = $computer.DistinguishedName
    }
}

if ($report.Count -eq 0) {
    Write-Host "No computer accounts found." -ForegroundColor Yellow
}
else {
    $windowsManagedCount = ($report | Where-Object { $_.WindowsLAPSManaged }).Count
    $expiredCount = ($report | Where-Object { $_.RotationStatus -eq "Expired" }).Count
    $expiringSoonCount = ($report | Where-Object { $_.RotationStatus -eq "Expiring Soon" }).Count
    $legacyOnlyCount = ($report | Where-Object { $_.RotationStatus -eq "Legacy Only" }).Count
    $bothCount = ($report | Where-Object { $_.LAPSMode -eq "Windows and Legacy" }).Count

    Write-Host "Retrieved $($report.Count) computer record(s)." -ForegroundColor Green
    Write-Host "  Windows LAPS managed: $windowsManagedCount" -ForegroundColor Yellow
    Write-Host "  Windows LAPS expired or overdue: $expiredCount" -ForegroundColor Yellow
    Write-Host "  Windows LAPS expiring within $ExpiringWithinDays day(s): $expiringSoonCount" -ForegroundColor Yellow
    Write-Host "  Legacy-only LAPS devices: $legacyOnlyCount" -ForegroundColor Yellow
    Write-Host "  Devices showing both legacy and Windows LAPS timestamps: $bothCount" -ForegroundColor Yellow

    $report |
        Sort-Object @{ Expression = {
                switch ($_.RotationStatus) {
                    "Expired" { 0 }
                    "Expiring Soon" { 1 }
                    "Scheduled" { 2 }
                    "Legacy Only" { 3 }
                    "Not Configured" { 4 }
                    "Schema Missing" { 5 }
                    default { 6 }
                }
            }
        }, DaysUntilWindowsLAPSExpiry, Name |
        Format-Table Name, LAPSMode, RotationStatus, WindowsLAPSPasswordExpiryUtc, DaysUntilWindowsLAPSExpiry, LastLogonDate -AutoSize
}
