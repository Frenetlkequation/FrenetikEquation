<#
.SYNOPSIS
Reports on Exchange Online mailbox folder permissions.

.DESCRIPTION
This script inventories mailbox folder permissions for access review and support.

.EXAMPLE
.\Get-ExchangeMailboxFolderPermissionReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Retrieving mailbox folder permissions..." -ForegroundColor Cyan
$mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox

$report = foreach ($mailbox in $mailboxes) {
    $folders = @("Inbox", "Calendar", "Sent Items")
    foreach ($folder in $folders) {
        $folderPermissions = Get-MailboxFolderPermission -Identity "$($mailbox.UserPrincipalName):\$folder" -ErrorAction SilentlyContinue
        foreach ($permission in @($folderPermissions)) {
            [PSCustomObject]@{
                Mailbox      = $mailbox.UserPrincipalName
                Folder       = $folder
                User         = $permission.User
                AccessRights = ($permission.AccessRights -join ", ")
            }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No mailbox folder permissions found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) folder permission record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
