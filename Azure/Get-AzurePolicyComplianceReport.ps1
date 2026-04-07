<#
.SYNOPSIS
Reports on Azure Policy non-compliance across subscriptions.

.DESCRIPTION
This script retrieves non-compliant Azure Policy states across enabled
subscriptions and reports on the affected resources, assignments, and policy
definitions for governance review.

.EXAMPLE
.\Get-AzurePolicyComplianceReport.ps1

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
#Requires -Module Az.PolicyInsights

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $nonCompliantStates = Get-AzPolicyState -Filter "ComplianceState eq 'NonCompliant'" -Top 1000 -ErrorAction SilentlyContinue

    foreach ($state in $nonCompliantStates) {
        [PSCustomObject]@{
            SubscriptionName        = $sub.Name
            ResourceGroup           = $state.ResourceGroup
            ResourceName            = $state.ResourceId.Split('/')[-1]
            ResourceType            = $state.ResourceType
            ComplianceState         = $state.ComplianceState
            PolicyAssignmentName     = $state.PolicyAssignmentName
            PolicyDefinitionName    = $state.PolicyDefinitionName
            PolicySetDefinitionName = $state.PolicySetDefinitionName
            PolicyDefinitionId      = $state.PolicyDefinitionId
            ResourceId              = $state.ResourceId
            ResourceLocation        = $state.ResourceLocation
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No non-compliant Azure Policy states found." -ForegroundColor Yellow
}
else {
    $nonCompliantResources = ($report | Select-Object -ExpandProperty ResourceId -Unique).Count
    $policyAssignments = ($report | Select-Object -ExpandProperty PolicyAssignmentName -Unique).Count
    $policyDefinitions = ($report | Select-Object -ExpandProperty PolicyDefinitionName -Unique).Count

    Write-Host "Retrieved $($report.Count) non-compliant policy state record(s)." -ForegroundColor Green
    Write-Host "  Non-compliant resources: $nonCompliantResources" -ForegroundColor Yellow
    Write-Host "  Policy assignments affected: $policyAssignments" -ForegroundColor Yellow
    Write-Host "  Policy definitions affected: $policyDefinitions" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
