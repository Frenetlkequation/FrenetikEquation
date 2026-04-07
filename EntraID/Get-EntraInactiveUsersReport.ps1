<#
.SYNOPSIS
Reports on inactive Entra ID user accounts.

.DESCRIPTION
This script identifies Entra ID user accounts that have not signed in within
the configured threshold and reports them for cleanup, access review, and
security auditing.

.PARAMETER DaysInactive
Number of days since last sign-in used to flag a user as inactive. Default is 90.

.EXAMPLE
.\Get-EntraInactiveUsersReport.ps1 -DaysInactive 60

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
    [int]$DaysInactive = 90
)

#Requires -Module Microsoft.Graph.Users

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All" -NoWelcome

$cutoffDate = (Get-Date).AddDays(-$DaysInactive)

Write-Host "Retrieving Entra ID users..." -ForegroundColor Cyan

$report = foreach ($user in (Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, Mail, AccountEnabled, CreatedDateTime, UserType, SignInActivity)) {
    if ($user.UserType -ne "Member") {
        continue
    }

    $lastSignIn = $user.SignInActivity.LastSignInDateTime
    $daysSince = if ($lastSignIn) {
        [math]::Round(((Get-Date) - $lastSignIn).TotalDays, 0)
    }
    else {
        $null
    }

    $isInactive = -not $lastSignIn -or $lastSignIn -lt $cutoffDate

    if ($isInactive) {
        [PSCustomObject]@{
            DisplayName         = $user.DisplayName
            UserPrincipalName   = $user.UserPrincipalName
            Mail                = $user.Mail
            AccountEnabled      = $user.AccountEnabled
            CreatedDateTime     = $user.CreatedDateTime
            LastSignInDateTime  = $lastSignIn
            DaysSinceLastSignIn = if ($daysSince -ne $null) { $daysSince } else { "Never" }
            Status              = if ($lastSignIn) { "Inactive" } else { "Never Signed In" }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No inactive users found." -ForegroundColor Green
}
else {
    $neverSignedIn = ($report | Where-Object { $_.Status -eq "Never Signed In" }).Count
    $inactive = ($report | Where-Object { $_.Status -eq "Inactive" }).Count

    Write-Host "Found $($report.Count) inactive user(s)." -ForegroundColor Yellow
    Write-Host "  Never signed in: $neverSignedIn" -ForegroundColor Yellow
    Write-Host "  Last sign-in older than $DaysInactive days: $inactive" -ForegroundColor Yellow
    $report | Sort-Object Status, DisplayName | Format-Table -AutoSize
}
