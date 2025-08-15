# Changelog

All notable changes to PublicIPWatcher will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub repository and CI/CD pipeline
- Comprehensive documentation
- Issue templates for bug reports and feature requests

## [1.0.0] - 2024-08-16

### Added
- Initial release of PublicIPWatcher
- System tray integration with Windows
- Automatic public IP address monitoring
- Balloon notifications for IP address changes
- Configurable check intervals (1 minute to 24 hours)
- Status window with current IP and countdown display
- Quick copy IP to clipboard functionality
- Windows startup integration option
- Comprehensive logging system with rolling files
- Self-contained executable deployment
- Single instance enforcement
- Retry logic with exponential backoff for network requests
- Fallback IP services for reliability
- Professional installer scripts and documentation

### Technical Details
- Built with .NET 8 and Windows Forms
- Uses HttpClient with proper timeout handling
- Persistent settings storage
- Professional error handling and logging
- Memory efficient system tray application
- No administrator privileges required

### Supported Platforms
- Windows 10 (version 1809 or later)
- Windows 11
- 64-bit (x64) architecture only

[Unreleased]: https://github.com/yourusername/PublicIPWatcher/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/PublicIPWatcher/releases/tag/v1.0.0
