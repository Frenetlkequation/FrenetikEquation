<#
.SYNOPSIS
Reports on AD Remote management configuration.

.DESCRIPTION
This script gathers AD Remote management configuration data and formats a PSCustomObject report for quick review.

.EXAMPLE
.\Get-ADDCRemoteManagementConfigurationReport.ps1

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

Write-Host "Retrieving domain controller Remote management configuration report..." -ForegroundColor Cyan

try {
    $domainControllers = Get-ADDomainController -Filter * -ErrorAction Stop | Sort-Object HostName

    $report = foreach ($dc in $domainControllers) {
        $ping = Test-Connection -ComputerName $dc.HostName -Count 1 -Quiet -ErrorAction SilentlyContinue
        $ldap = Test-NetConnection -ComputerName $dc.HostName -Port 389 -InformationLevel Quiet -WarningAction SilentlyContinue

        [PSCustomObject]@{
            ReportType      = 'Remote management configuration'
            HostName        = $dc.HostName
            Site            = $dc.Site
            IPv4Address     = $dc.IPv4Address
            OperatingSystem = $dc.OperatingSystem
            OSVersion       = $dc.OperatingSystemVersion
            IsGlobalCatalog = $dc.IsGlobalCatalog
            PingReachable   = $ping
            LDAPReachable   = $ldap
            Status          = if ($ping -and $ldap) { 'Healthy' } elseif ($ping) { 'LDAP Issue' } else { 'Unreachable' }
        }
    }

    if (@($report).Count -eq 0) {
        Write-Host "No domain controllers were returned." -ForegroundColor Yellow
    }
    else {
        Write-Host "Retrieved $(@($report).Count) domain controller record(s)." -ForegroundColor Green
        $report | Format-Table -AutoSize
    }
}
catch {
    Write-Host "Failed to build domain controller report: $($_.Exception.Message)" -ForegroundColor Red
}

