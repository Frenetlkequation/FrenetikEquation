<#
.SYNOPSIS
Reports on Windows Firewall profile configuration.

.DESCRIPTION
This script retrieves firewall profile settings from local or remote computers
for security and compliance review.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-FirewallProfileReport.ps1 -ComputerName "Server01"

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
    [string[]]$ComputerName = $env:COMPUTERNAME
)

#Requires -Module NetSecurity

Write-Host "Retrieving firewall profile configuration..." -ForegroundColor Cyan

$scriptBlock = {
    Get-NetFirewallProfile | ForEach-Object {
        [PSCustomObject]@{
            ComputerName            = $env:COMPUTERNAME
            ProfileName             = $_.Name
            Enabled                 = $_.Enabled
            DefaultInboundAction    = $_.DefaultInboundAction
            DefaultOutboundAction   = $_.DefaultOutboundAction
            AllowLocalFirewallRules = $_.AllowLocalFirewallRules
            NotifyOnListen          = $_.NotifyOnListen
        }
    }
}

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        if ($computer -in @($env:COMPUTERNAME, 'localhost', '.')) {
            & $scriptBlock
        }
        else {
            Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ErrorAction Stop
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No firewall data collected." -ForegroundColor Yellow
}
else {
    $disabled = ($report | Where-Object { $_.Enabled -eq $false }).Count
    Write-Host "Retrieved $($report.Count) firewall profile record(s)." -ForegroundColor Green
    if ($disabled -gt 0) {
        Write-Host "  WARNING: $disabled profile(s) are disabled." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
