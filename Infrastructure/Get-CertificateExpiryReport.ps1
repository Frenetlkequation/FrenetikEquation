<#
.SYNOPSIS
Reports on SSL/TLS certificate expiration for remote endpoints.

.DESCRIPTION
This script checks SSL/TLS certificates on specified endpoints and reports
on their validity, expiration dates, and issuer information for proactive
certificate management.

.PARAMETER Endpoints
Array of hostnames to check. Default includes common Microsoft endpoints.

.PARAMETER Port
TCP port to connect to. Default is 443.

.EXAMPLE
.\Get-CertificateExpiryReport.ps1 -Endpoints "mail.contoso.com", "portal.contoso.com"

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string[]]$Endpoints = @(
        "login.microsoftonline.com"
        "outlook.office365.com"
        "graph.microsoft.com"
    ),

    [Parameter()]
    [int]$Port = 443
)

Write-Host "Checking SSL/TLS certificates..." -ForegroundColor Cyan

$report = foreach ($endpoint in $Endpoints) {
    Write-Host "  Checking: $endpoint`:$Port" -ForegroundColor Cyan

    try {
        $tcpClient = [System.Net.Sockets.TcpClient]::new()
        $tcpClient.Connect($endpoint, $Port)

        $sslStream = [System.Net.Security.SslStream]::new($tcpClient.GetStream(), $false, { $true })
        $sslStream.AuthenticateAsClient($endpoint)

        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($sslStream.RemoteCertificate)

        $daysRemaining = [math]::Round(($cert.NotAfter - (Get-Date)).TotalDays, 0)
        $status = if ($daysRemaining -lt 0) { "Expired" }
                  elseif ($daysRemaining -lt 30) { "Expiring Soon" }
                  else { "Valid" }

        [PSCustomObject]@{
            Endpoint      = $endpoint
            Port          = $Port
            Subject       = $cert.Subject
            Issuer        = $cert.Issuer
            NotBefore     = $cert.NotBefore
            NotAfter      = $cert.NotAfter
            DaysRemaining = $daysRemaining
            Thumbprint    = $cert.Thumbprint
            Status        = $status
        }

        $sslStream.Dispose()
        $tcpClient.Dispose()
    }
    catch {
        [PSCustomObject]@{
            Endpoint      = $endpoint
            Port          = $Port
            Subject       = "N/A"
            Issuer        = "N/A"
            NotBefore     = "N/A"
            NotAfter      = "N/A"
            DaysRemaining = "N/A"
            Thumbprint    = "N/A"
            Status        = "Connection Failed: $_"
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No endpoints checked." -ForegroundColor Yellow
}
else {
    $issues = ($report | Where-Object { $_.Status -ne "Valid" }).Count
    Write-Host "Checked $($report.Count) endpoint(s). Issues: $issues" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
