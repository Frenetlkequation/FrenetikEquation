<#
.SYNOPSIS
Reports on Exchange Online organization configuration.

.DESCRIPTION
This script reviews organization-wide Exchange settings for tenant administration.

.EXAMPLE
.\Get-ExchangeOrganizationConfigReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving organization configuration..." -ForegroundColor Cyan
$config = Get-OrganizationConfig

$report = [PSCustomObject]@{
    Name                           = $config.Name
    DisplayName                    = $config.DisplayName
    DefaultPublicFolderAgeLimit     = $config.DefaultPublicFolderAgeLimit
    IsDehydrated                   = $config.IsDehydrated
    OAuth2ClientProfileEnabled      = $config.OAuth2ClientProfileEnabled
    SmtpClientAuthenticationDisabled = $config.SmtpClientAuthenticationDisabled
}

Write-Host "Retrieved organization configuration." -ForegroundColor Green
$report | Format-Table -AutoSize
