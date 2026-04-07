<#
.SYNOPSIS
Reports on Azure public IP addresses.

.DESCRIPTION
This script retrieves Azure public IP addresses across subscriptions and
reports on allocation method, address assignment, and resource association
for inventory and security review.

.EXAMPLE
.\Get-AzurePublicIPReport.ps1

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
param ()

#Requires -Module Az.Accounts
#Requires -Module Az.Network

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $publicIpAddresses = Get-AzPublicIpAddress

    foreach ($publicIp in $publicIpAddresses) {
        $ipConfigurationId = if ($publicIp.IpConfiguration -and $publicIp.IpConfiguration.Id) {
            $publicIp.IpConfiguration.Id
        }
        elseif ($publicIp.IpConfigurationText) {
            $publicIp.IpConfigurationText
        }
        else {
            $null
        }

        $associatedResource = if ($ipConfigurationId) {
            $ipConfigurationId -replace "/ipConfigurations/.*$", ""
        }
        else {
            "Unassociated"
        }

        [PSCustomObject]@{
            SubscriptionName     = $sub.Name
            ResourceGroup        = $publicIp.ResourceGroupName
            PublicIpName         = $publicIp.Name
            Location             = $publicIp.Location
            IpAddress            = $publicIp.IpAddress
            Version              = $publicIp.PublicIpAddressVersion
            AllocationMethod     = $publicIp.PublicIpAllocationMethod
            Sku                  = if ($publicIp.Sku) { $publicIp.Sku.Name } else { "Basic" }
            DnsNameLabel         = if ($publicIp.DnsSettings -and $publicIp.DnsSettings.DomainNameLabel) { $publicIp.DnsSettings.DomainNameLabel } else { "None" }
            AssociatedResource   = $associatedResource
            IdleTimeoutInMinutes = $publicIp.IdleTimeoutInMinutes
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No public IP addresses found." -ForegroundColor Yellow
}
else {
    $unassociated = ($report | Where-Object { $_.AssociatedResource -eq "Unassociated" }).Count
    $static = ($report | Where-Object { $_.AllocationMethod -eq "Static" }).Count

    Write-Host "Retrieved $($report.Count) public IP address(es)." -ForegroundColor Green
    Write-Host "  Static: $static" -ForegroundColor Yellow
    Write-Host "  Unassociated: $unassociated" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
