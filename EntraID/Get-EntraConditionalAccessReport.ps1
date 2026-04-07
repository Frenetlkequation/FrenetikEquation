<#
.SYNOPSIS
Reports on Entra ID Conditional Access policies.

.DESCRIPTION
This script retrieves Conditional Access policies from Entra ID and reports
on their state, target conditions, and grant controls for security review
and compliance documentation.

.EXAMPLE
.\Get-EntraConditionalAccessReport.ps1

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

#Requires -Module Microsoft.Graph.Identity.SignIns

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

Write-Host "Retrieving Conditional Access policies..." -ForegroundColor Cyan

$policies = Get-MgIdentityConditionalAccessPolicy -All

$report = foreach ($policy in $policies) {
    $includeUsers = $policy.Conditions.Users.IncludeUsers -join ", "
    $excludeUsers = $policy.Conditions.Users.ExcludeUsers -join ", "
    $includeApps = $policy.Conditions.Applications.IncludeApplications -join ", "
    $grantControls = $policy.GrantControls.BuiltInControls -join ", "
    $platforms = $policy.Conditions.Platforms.IncludePlatforms -join ", "

    [PSCustomObject]@{
        PolicyName      = $policy.DisplayName
        State           = $policy.State
        IncludeUsers    = if ($includeUsers) { $includeUsers } else { "None" }
        ExcludeUsers    = if ($excludeUsers) { $excludeUsers } else { "None" }
        IncludeApps     = if ($includeApps) { $includeApps } else { "None" }
        Platforms       = if ($platforms) { $platforms } else { "All" }
        GrantControls   = if ($grantControls) { $grantControls } else { "None" }
        SessionControls = if ($policy.SessionControls) { "Configured" } else { "None" }
        CreatedDateTime = $policy.CreatedDateTime
        ModifiedDateTime = $policy.ModifiedDateTime
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Conditional Access policies found." -ForegroundColor Yellow
}
else {
    $enabled = ($report | Where-Object { $_.State -eq "enabled" }).Count
    $reportOnly = ($report | Where-Object { $_.State -eq "enabledForReportingButNotEnforced" }).Count
    $disabled = ($report | Where-Object { $_.State -eq "disabled" }).Count

    Write-Host "Retrieved $($report.Count) policy(ies). Enabled: $enabled, Report-only: $reportOnly, Disabled: $disabled" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
