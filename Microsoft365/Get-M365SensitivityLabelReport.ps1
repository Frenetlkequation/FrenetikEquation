<#
.SYNOPSIS
Reports on Microsoft 365 sensitivity labels.

.DESCRIPTION
This script inventories sensitivity labels for governance review.

.EXAMPLE
.\Get-M365SensitivityLabelReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "InformationProtectionPolicy.Read.All" -NoWelcome

Write-Host "Retrieving sensitivity labels..." -ForegroundColor Cyan
$response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/informationProtection/sensitivityLabels" -OutputType HttpResponseMessage
$stream = $response.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$json = $reader.ReadToEnd()
$reader.Close()

$labels = ($json | ConvertFrom-Json).value

$report = foreach ($label in $labels) {
    [PSCustomObject]@{
        Name        = $label.name
        Id          = $label.id
        Tooltip     = $label.tooltip
        Priority    = $label.priority
    }
}

Write-Host "Retrieved $($report.Count) sensitivity label record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
