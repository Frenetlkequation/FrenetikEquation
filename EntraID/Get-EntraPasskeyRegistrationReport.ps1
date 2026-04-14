<#
.SYNOPSIS
Reports on Entra ID passkey registration coverage.

.DESCRIPTION
This script retrieves Microsoft Entra authentication method registration details
from Microsoft Graph and highlights users with registered passkeys, passwordless
capability, and current registered authentication methods.

.PARAMETER RegisteredOnly
Only display users with one or more registered passkey methods.

.EXAMPLE
.\Get-EntraPasskeyRegistrationReport.ps1

.EXAMPLE
.\Get-EntraPasskeyRegistrationReport.ps1 -RegisteredOnly

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
    [switch]$RegisteredOnly
)

#Requires -Module Microsoft.Graph.Authentication

function Get-GraphCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Uri
    )

    $items = @()
    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType PSObject
        if ($response.value) {
            $items += $response.value
        }
        $Uri = $response.'@odata.nextLink'
    } while ($Uri)

    return $items
}

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "AuditLog.Read.All" -NoWelcome

Write-Host "Retrieving Entra ID authentication method registration details..." -ForegroundColor Cyan

$allUsers = Get-GraphCollection -Uri "https://graph.microsoft.com/v1.0/reports/authenticationMethods/userRegistrationDetails"

$report = foreach ($row in $allUsers) {
    $methods = @($row.methodsRegistered | Where-Object { $_ })
    $systemPreferred = @($row.systemPreferredAuthenticationMethods | Where-Object { $_ })

    # Graph passkey registration identifiers currently use the passKey* naming pattern.
    $passkeyMethods = @($methods | Where-Object { $_ -like "passKey*" })

    [PSCustomObject]@{
        UserDisplayName                       = $row.userDisplayName
        UserPrincipalName                     = $row.userPrincipalName
        UserType                              = if ($row.userType) { $row.userType } else { "Unknown" }
        PasskeyRegistered                     = $passkeyMethods.Count -gt 0
        PasskeyMethods                        = if ($passkeyMethods.Count -gt 0) { $passkeyMethods -join "; " } else { "None" }
        MFARegistered                         = [bool]$row.isMfaRegistered
        MFACapable                            = [bool]$row.isMfaCapable
        PasswordlessCapable                   = [bool]$row.isPasswordlessCapable
        MethodsRegistered                     = if ($methods.Count -gt 0) { $methods -join "; " } else { "None" }
        SystemPreferredAuthenticationMethods  = if ($systemPreferred.Count -gt 0) { $systemPreferred -join "; " } else { "None" }
        LastUpdatedDateTime                   = $row.lastUpdatedDateTime
    }
}

$displayReport = if ($RegisteredOnly) {
    $report | Where-Object { $_.PasskeyRegistered }
}
else {
    $report
}

if ($report.Count -eq 0) {
    Write-Host "No authentication registration records found." -ForegroundColor Yellow
}
else {
    $passkeyRegisteredCount = ($report | Where-Object { $_.PasskeyRegistered }).Count
    $passwordlessCapableCount = ($report | Where-Object { $_.PasswordlessCapable }).Count
    $mfaRegisteredCount = ($report | Where-Object { $_.MFARegistered }).Count

    Write-Host "Retrieved $($report.Count) authentication registration record(s)." -ForegroundColor Green
    Write-Host "  Passkey registered: $passkeyRegisteredCount" -ForegroundColor Yellow
    Write-Host "  Passwordless capable: $passwordlessCapableCount" -ForegroundColor Yellow
    Write-Host "  MFA registered: $mfaRegisteredCount" -ForegroundColor Yellow

    if ($RegisteredOnly) {
        Write-Host "Displaying only users with registered passkeys." -ForegroundColor Cyan
    }

    if ($displayReport.Count -eq 0) {
        Write-Host "No users matched the selected filter." -ForegroundColor Yellow
    }
    else {
        $displayReport |
            Sort-Object @{ Expression = { if ($_.PasskeyRegistered) { 0 } else { 1 } } }, UserDisplayName |
            Format-Table UserDisplayName, UserPrincipalName, UserType, PasskeyRegistered, PasskeyMethods, PasswordlessCapable, LastUpdatedDateTime -AutoSize
    }
}
