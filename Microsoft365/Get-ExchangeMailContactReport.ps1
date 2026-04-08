<#
.SYNOPSIS
Reports on Exchange Online mail contacts.

.DESCRIPTION
This script inventories mail contacts used for external collaboration.

.EXAMPLE
.\Get-ExchangeMailContactReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mail contacts..." -ForegroundColor Cyan
$contacts = Get-MailContact -ResultSize Unlimited

$report = foreach ($contact in $contacts) {
    [PSCustomObject]@{
        DisplayName       = $contact.DisplayName
        PrimarySmtpAddress = $contact.PrimarySmtpAddress
        ExternalEmailAddress = $contact.ExternalEmailAddress
        HiddenFromAddressListsEnabled = $contact.HiddenFromAddressListsEnabled
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mail contacts found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) mail contact record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
