# Contributing to PublicIPWatcher

Thank you for your interest in contributing to PublicIPWatcher! This document provides guidelines and information for contributors.

## Code of Conduct

This project follows a simple code of conduct:
- Be respectful and inclusive
- Focus on constructive feedback
- Help maintain a welcoming environment for all contributors

## How to Contribute

### Reporting Issues

Before creating an issue, please:
1. Check if the issue already exists
2. Include detailed information about the problem
3. Provide steps to reproduce the issue
4. Include system information (Windows version, etc.)

### Feature Requests

We welcome feature suggestions! Please:
1. Check existing issues for similar requests
2. Clearly describe the proposed feature
3. Explain the use case and benefits
4. Consider the scope and complexity

### Pull Requests

1. **Fork** the repository
2. **Create** a feature branch from `main`
3. **Make** your changes following the coding standards
4. **Test** your changes thoroughly
5. **Update** documentation if needed
6. **Submit** a pull request with a clear description

## Development Setup

### Prerequisites

- Visual Studio 2022 (Community or higher)
- .NET 8 SDK
- Windows 10/11 development environment
- Git for Windows

### Getting Started

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/yourusername/PublicIPWatcher.git
   cd PublicIPWatcher
   ```

2. Open the solution in Visual Studio:
   ```
   IPNotification.sln
   ```

3. Build and run the project:
   - Set `IPNotification` as the startup project
   - Press F5 to run in debug mode

## Coding Standards

### General Guidelines

- Follow C# naming conventions
- Use meaningful variable and method names
- Add XML documentation for public methods
- Keep methods focused and reasonably sized
- Use async/await properly for I/O operations

### Code Style

- Use 4 spaces for indentation
- Place opening braces on the same line for methods and classes
- Use `var` when the type is obvious
- Prefer explicit access modifiers
- Order using statements alphabetically

### Example:

```csharp
/// <summary>
/// Fetches the current public IP address
/// </summary>
/// <returns>The IP address or null if failed</returns>
public async Task<string?> GetPublicIpAsync()
{
    try
    {
        var response = await _httpClient.GetStringAsync(_endpoint);
        return response.Trim();
    }
    catch (Exception ex)
    {
        Logging.Log($"Error fetching IP: {ex.Message}");
        return null;
    }
}
```

## Project Structure

```
IPNotification/
├── IPNotification/           # Main application
│   ├── Program.cs           # Entry point
│   ├── TrayAppContext.cs    # Application context
│   ├── StatusForm.cs        # UI components
│   ├── IpFetcher.cs         # Core functionality
│   └── Logging.cs           # Utilities
├── Installer/               # Installation files
├── Deploy.ps1              # Build scripts
└── docs/                   # Documentation
```

## Testing

### Manual Testing

1. Build the application in Release mode
2. Test basic functionality:
   - System tray integration
   - IP fetching and display
   - Change notifications
   - Settings persistence
   - Startup integration

3. Test edge cases:
   - Network disconnection
   - Invalid responses from IP services
   - Multiple instances
   - Windows restart behavior

### Adding Tests

While this project currently uses manual testing, we welcome contributions that add:
- Unit tests for core logic
- Integration tests for network operations
- UI automation tests

## Documentation

### Code Documentation

- Add XML documentation for public methods
- Include parameter descriptions and return values
- Document any complex algorithms or business logic

### User Documentation

- Update README.md for new features
- Modify DEPLOYMENT.md for installation changes
- Add examples for new configuration options

## Release Process

### Version Numbering

We use semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes

### Preparing a Release

1. Update version numbers in:
   - `IPNotification.csproj`
   - `AssemblyInfo.cs` (if applicable)
   - README.md changelog

2. Test the release build thoroughly
3. Update documentation
4. Create release notes

## Getting Help

- **Questions**: Open a GitHub issue with the "question" label
- **Discussions**: Use GitHub Discussions for general topics
- **Documentation**: Check existing docs in the repository

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors graph

Thank you for contributing to PublicIPWatcher! 🎉
