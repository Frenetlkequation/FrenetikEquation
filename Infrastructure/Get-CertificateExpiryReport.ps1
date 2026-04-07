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
