<#
.SYNOPSIS
Reports on Exchange Online transport configuration.

.DESCRIPTION
This script reviews organization transport settings for mail flow governance.

.EXAMPLE
.\Get-ExchangeTransportConfigReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving transport configuration..." -ForegroundColor Cyan
$config = Get-TransportConfig

$report = [PSCustomObject]@{
    Name                        = $config.Name
    SmtpClientAuthenticationDisabled = $config.SmtpClientAuthenticationDisabled
    MaxSendSize                 = $config.MaxSendSize
    MaxReceiveSize              = $config.MaxReceiveSize
    ExternalRecipientLimit      = $config.ExternalRecipientLimit
}

Write-Host "Retrieved transport configuration." -ForegroundColor Green
$report | Format-Table -AutoSize
