<#
.SYNOPSIS
Reports on Azure SQL databases and their configuration.

.DESCRIPTION
This script retrieves Azure SQL servers and databases across subscriptions
and reports on their tier, size, backup settings, and firewall rules
for operational and security review.

.EXAMPLE
.\Get-AzureSQLDatabaseReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module Az.Accounts
#Requires -Module Az.Sql

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $sqlServers = Get-AzSqlServer -ErrorAction SilentlyContinue

    foreach ($server in $sqlServers) {
        $firewallRules = Get-AzSqlServerFirewallRule -ServerName $server.ServerName -ResourceGroupName $server.ResourceGroupName -ErrorAction SilentlyContinue
        $allowAllAzure = ($firewallRules | Where-Object { $_.StartIpAddress -eq "0.0.0.0" -and $_.EndIpAddress -eq "0.0.0.0" }).Count -gt 0
        $openRules = ($firewallRules | Where-Object { $_.StartIpAddress -eq "0.0.0.0" -and $_.EndIpAddress -eq "255.255.255.255" }).Count -gt 0

        $databases = Get-AzSqlDatabase -ServerName $server.ServerName -ResourceGroupName $server.ResourceGroupName -ErrorAction SilentlyContinue |
            Where-Object { $_.DatabaseName -ne "master" }

        foreach ($db in $databases) {
            [PSCustomObject]@{
                SubscriptionName  = $sub.Name
                ResourceGroup     = $server.ResourceGroupName
                ServerName        = $server.ServerName
                DatabaseName      = $db.DatabaseName
                Status            = $db.Status
                Edition           = $db.Edition
                ServiceObjective  = $db.CurrentServiceObjectiveName
                MaxSizeGB         = [math]::Round($db.MaxSizeBytes / 1GB, 2)
                Location          = $db.Location
                FirewallRuleCount = $firewallRules.Count
                AllowAllAzure     = $allowAllAzure
                OpenToInternet    = $openRules
            }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No SQL databases found." -ForegroundColor Yellow
}
else {
    $openToInternet = ($report | Where-Object { $_.OpenToInternet }).Count
    Write-Host "Retrieved $($report.Count) database(s)." -ForegroundColor Green
    if ($openToInternet -gt 0) { Write-Host "  WARNING: $openToInternet server(s) open to all internet traffic." -ForegroundColor Red }
    $report | Format-Table -AutoSize
}
