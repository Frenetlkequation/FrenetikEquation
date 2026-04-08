<#
.SYNOPSIS
Reports on DHCP lease scopes.

.DESCRIPTION
This script inventories DHCP scopes and lease settings for server administration and documentation.

.EXAMPLE
.\Get-DHCPLeaseScopeReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module DhcpServer

Write-Host "Retrieving DHCP scopes..." -ForegroundColor Cyan

$report = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        ScopeId       = $_.ScopeId
        Name          = $_.Name
        StartRange    = $_.StartRange
        EndRange      = $_.EndRange
        SubnetMask    = $_.SubnetMask
        State         = $_.State
        LeaseDuration = $_.LeaseDuration
    }
}

if ($report.Count -eq 0) {
    Write-Host "No DHCP scopes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) DHCP scope record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
