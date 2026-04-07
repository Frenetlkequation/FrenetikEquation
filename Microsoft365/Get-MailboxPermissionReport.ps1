<#
.SYNOPSIS
Reports on mailbox permission assignments in Exchange Online.

.DESCRIPTION
This script retrieves mailbox delegation settings from Exchange Online,
including mailbox permissions, Send As permissions, and Send on Behalf
delegation for auditing and access review.

.PARAMETER IncludeInheritedPermissions
Includes inherited mailbox permissions in the report.

.EXAMPLE
.\Get-MailboxPermissionReport.ps1

.EXAMPLE
.\Get-MailboxPermissionReport.ps1 -IncludeInheritedPermissions

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
    [switch]$IncludeInheritedPermissions
)

#Requires -Module ExchangeOnlineManagement

function Get-DelegateDisplayName {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object]$Delegate
    )

    if ($null -eq $Delegate) {
        return $null
    }

    if ($Delegate -is [string]) {
        return $Delegate
    }

    if ($Delegate.PSObject.Properties.Name -contains "DisplayName" -and $Delegate.DisplayName) {
        return $Delegate.DisplayName
    }

    if ($Delegate.PSObject.Properties.Name -contains "Name" -and $Delegate.Name) {
        return $Delegate.Name
    }

    return [string]$Delegate
}

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox permission assignments..." -ForegroundColor Cyan

$mailboxes = Get-EXOMailbox -RecipientTypeDetails UserMailbox, SharedMailbox -ResultSize Unlimited -Properties GrantSendOnBehalfTo

$report = foreach ($mailbox in $mailboxes) {
    $mailboxPermissions = Get-EXOMailboxPermission -Identity $mailbox.UserPrincipalName -ErrorAction SilentlyContinue |
        Where-Object {
            $_.User -ne "NT AUTHORITY\SELF" -and
            ($IncludeInheritedPermissions.IsPresent -or $_.IsInherited -eq $false)
        }

    foreach ($permission in $mailboxPermissions) {
        [PSCustomObject]@{
            DisplayName        = $mailbox.DisplayName
            UserPrincipalName  = $mailbox.UserPrincipalName
            RecipientType      = $mailbox.RecipientTypeDetails
            PermissionType     = "MailboxPermission"
            Trustee            = $permission.User
            AccessRights       = ($permission.AccessRights -join ", ")
            IsInherited        = $permission.IsInherited
        }
    }

    $sendAsPermissions = Get-EXORecipientPermission -Identity $mailbox.UserPrincipalName -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Trustee -ne "NT AUTHORITY\SELF" -and
            $_.AccessRights -contains "SendAs"
        }

    foreach ($permission in $sendAsPermissions) {
        [PSCustomObject]@{
            DisplayName        = $mailbox.DisplayName
            UserPrincipalName  = $mailbox.UserPrincipalName
            RecipientType      = $mailbox.RecipientTypeDetails
            PermissionType     = "SendAs"
            Trustee            = $permission.Trustee
            AccessRights       = "SendAs"
            IsInherited        = $false
        }
    }

    foreach ($delegate in $mailbox.GrantSendOnBehalfTo) {
        [PSCustomObject]@{
            DisplayName        = $mailbox.DisplayName
            UserPrincipalName  = $mailbox.UserPrincipalName
            RecipientType      = $mailbox.RecipientTypeDetails
            PermissionType     = "SendOnBehalf"
            Trustee            = Get-DelegateDisplayName -Delegate $delegate
            AccessRights       = "SendOnBehalf"
            IsInherited        = $false
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mailbox permission assignments found." -ForegroundColor Yellow
}
else {
    $mailboxCount = ($report | Select-Object -ExpandProperty UserPrincipalName -Unique).Count
    $sendAs = ($report | Where-Object { $_.PermissionType -eq "SendAs" }).Count
    $sendOnBehalf = ($report | Where-Object { $_.PermissionType -eq "SendOnBehalf" }).Count

    Write-Host "Retrieved $($report.Count) mailbox permission assignment(s) across $mailboxCount mailbox(es)." -ForegroundColor Green
    Write-Host "  Send As assignments: $sendAs" -ForegroundColor Yellow
    Write-Host "  Send on Behalf assignments: $sendOnBehalf" -ForegroundColor Yellow
    $report | Sort-Object DisplayName, PermissionType, Trustee | Format-Table -AutoSize
}
