<#
.SYNOPSIS
Reports on active RDP sessions.

.DESCRIPTION
This script queries Remote Desktop sessions on local or remote computers and
reports user, session, and idle information for support review.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.EXAMPLE
.\Get-RDPSessionReport.ps1 -ComputerName "Server01"

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

Write-Host "Retrieving RDP sessions..." -ForegroundColor Cyan

$report = foreach ($computer in $ComputerName) {
    Write-Host "Querying: $computer" -ForegroundColor Cyan

    try {
        $output = if ($computer -in @($env:COMPUTERNAME, 'localhost', '.')) {
            cmd /c quser 2>$null
        }
        else {
            cmd /c "quser /server:$computer" 2>$null
        }

        if (-not $output) { continue }

        foreach ($line in $output | Select-Object -Skip 1) {
            if ($line -match '^\s*(?<User>\S+)\s+(?<SessionName>\S+)?\s*(?<Id>\d+)\s+(?<State>\S+)\s+(?<IdleTime>\S+)\s+(?<LogonTime>.+)$') {
                [PSCustomObject]@{
                    ComputerName = $computer
                    UserName     = $Matches.User
                    SessionName  = $Matches.SessionName
                    Id           = $Matches.Id
                    State        = $Matches.State
                    IdleTime     = $Matches.IdleTime
                    LogonTime    = $Matches.LogonTime.Trim()
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to query $computer : $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No RDP session data collected." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) session record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
