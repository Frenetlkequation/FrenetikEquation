<#
.SYNOPSIS
Reports on Microsoft 365 passwordless adoption.

.DESCRIPTION
This script reviews authentication method registration details for passwordless readiness.

.EXAMPLE
.\Get-M365PasswordlessAdoptionReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Reports.Read.All" -NoWelcome

Write-Host "Retrieving authentication method registration details..." -ForegroundColor Cyan
$response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/reports/authenticationMethods/userRegistrationDetails" -OutputType HttpResponseMessage
$stream = $response.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$csv = $reader.ReadToEnd()
$reader.Close()

$data = $csv | ConvertFrom-Csv
$report = foreach ($row in $data) {
    [PSCustomObject]@{
        UserPrincipalName = $row.'User Principal Name'
        IsMfaCapable      = $row.'Is MFA Capable'
        IsPasswordlessCapable = $row.'Is Passwordless Capable'
        AuthMethods       = $row.'Methods Registered'
    }
}

Write-Host "Retrieved $($report.Count) passwordless adoption record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
