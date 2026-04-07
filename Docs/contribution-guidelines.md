# Contribution Guidelines

Thank you for your interest in contributing to FrenetikEquation Scripts.

## How to Contribute

1. Fork the repository.
2. Create a feature branch from `main`.
3. Make your changes following the conventions below.
4. Submit a pull request with a clear description of the changes.

## Script Conventions

- Every script must include the standard header block with `.SYNOPSIS`, `.DESCRIPTION`, `.NOTES`, and `.EXAMPLE`.
- Author should be set to `FrenetikEquation`.
- Include `#Requires` statements for any required modules.
- Use `[CmdletBinding()]` and `param()` blocks.
- Use `Write-Host` with color for user-facing output.
- Avoid hardcoded credentials or secrets.

## Testing

- All scripts must be tested in a non-production environment before submitting.
- Include example usage in the script header.
- Contributors acknowledge that all contributed scripts are provided "AS IS" and subject to the legal disclaimer in the repository root [LICENSE](../LICENSE) file.

## Naming

- Use PascalCase with verb-noun naming: `Get-Something.ps1`, `Export-Something.ps1`.
- Place scripts in the appropriate category folder.

## Code of Conduct

Be respectful and constructive. We are all here to learn and improve.
