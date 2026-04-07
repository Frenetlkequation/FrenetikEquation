<#
.SYNOPSIS
Reports on Active Directory Organizational Unit structure.

.DESCRIPTION
This script retrieves the OU structure from Active Directory and reports
on each OU including the count of users, computers, and groups within it.
Useful for domain documentation and structure review.

.EXAMPLE
.\Get-ADOUStructureReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module ActiveDirectory

Write-Host "Retrieving Active Directory OU structure..." -ForegroundColor Cyan

$ous = Get-ADOrganizationalUnit -Filter * -Properties Description, WhenCreated | Sort-Object DistinguishedName

$report = foreach ($ou in $ous) {
    $users = (Get-ADUser -Filter * -SearchBase $ou.DistinguishedName -SearchScope OneLevel -ErrorAction SilentlyContinue).Count
    $computers = (Get-ADComputer -Filter * -SearchBase $ou.DistinguishedName -SearchScope OneLevel -ErrorAction SilentlyContinue).Count
    $groups = (Get-ADGroup -Filter * -SearchBase $ou.DistinguishedName -SearchScope OneLevel -ErrorAction SilentlyContinue).Count

    [PSCustomObject]@{
        OUName            = $ou.Name
        DistinguishedName = $ou.DistinguishedName
        Description       = $ou.Description
        UserCount         = $users
        ComputerCount     = $computers
        GroupCount        = $groups
        WhenCreated       = $ou.WhenCreated
    }
}

if ($report.Count -eq 0) {
    Write-Host "No OUs found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) OU(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
