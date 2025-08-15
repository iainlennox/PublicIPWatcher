# PublicIPWatcher

A lightweight Windows system tray application that monitors your public IP address and notifies you when it changes.

![Screenshot placeholder](docs/screenshot.png)

## Features

- 🖥️ **System Tray Integration** - Runs minimized in the system tray
- 🔄 **Automatic Monitoring** - Checks your public IP at configurable intervals (1 minute to 24 hours)
- 📢 **Change Notifications** - Balloon notifications when your IP address changes
- 📋 **Quick Copy** - Right-click to copy current IP to clipboard
- 🚀 **Windows Startup** - Optional automatic start with Windows
- 📊 **Status Window** - View current IP, last change time, and next check countdown
- 📝 **Detailed Logging** - Comprehensive logs for troubleshooting
- 🔒 **Privacy Focused** - No data collection, all information stays local
- 🎯 **Single Instance** - Prevents multiple instances from running
- 📦 **Self-Contained** - No .NET runtime installation required

## Quick Start

### Download & Install

1. **Download** the latest release from the [Releases](../../releases) page
2. **Extract** the ZIP file to any folder
3. **Run** `IPNotification.exe`
4. **Look** for the icon in your system tray (bottom-right corner)

### Usage

- **Right-click** the tray icon for the context menu
- **Double-click** the tray icon to view status
- **Copy IP** - Copies current public IP to clipboard
- **Check Now** - Forces an immediate IP check
- **Show Status** - Opens the status window

## System Requirements

- **OS**: Windows 10 (1809+) or Windows 11
- **Architecture**: 64-bit (x64)
- **RAM**: 50 MB
- **Disk**: 50 MB free space
- **Network**: Internet connection for IP checking

## Configuration

Access the status window to configure:

- **Check Interval**: 1 minute to 24 hours (default: 5 minutes)
- **Start with Windows**: Toggle automatic startup
- **Logging**: View and manage application logs

## Building from Source

### Prerequisites

- Visual Studio 2022 or later
- .NET 8 SDK
- Windows 10/11 development environment

### Build Steps

1. **Clone** the repository:
   ```bash
   git clone https://github.com/yourusername/PublicIPWatcher.git
   cd PublicIPWatcher
   ```

2. **Build** the solution:
   ```bash
   dotnet build IPNotification.sln
   ```

3. **Publish** self-contained executable:
   ```bash
   dotnet publish IPNotification\IPNotification.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o Deploy
   ```

4. **Or use** the deployment script:
   ```powershell
   .\Deploy.ps1 -Release
   ```

## Architecture

- **Framework**: .NET 8 with Windows Forms
- **Pattern**: System tray application with ApplicationContext
- **Networking**: HttpClient with retry logic and fallback endpoints
- **Configuration**: User settings with persistent storage
- **Logging**: Rolling file logs with rotation

### Project Structure

```
IPNotification/
├── IPNotification/           # Main application project
│   ├── Program.cs           # Application entry point
│   ├── TrayAppContext.cs    # Main application context
│   ├── StatusForm.cs        # Status window UI
│   ├── IpFetcher.cs         # IP fetching logic
│   └── Logging.cs           # Logging utilities
├── Installer/               # Installation packages
├── Deploy.ps1              # Deployment script
└── DEPLOYMENT.md           # Detailed deployment guide
```

## IP Services Used

- **Primary**: [api.ipify.org](https://api.ipify.org) 
- **Fallback**: [ifconfig.me](https://ifconfig.me)

Both services are reliable, free, and respect privacy.

## Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security & Privacy

- ✅ **No data collection** - Your information stays on your computer
- ✅ **Local storage only** - Settings and logs are stored locally
- ✅ **Minimal network access** - Only connects to IP checking services
- ✅ **No admin privileges** - Runs with regular user permissions
- ✅ **Open source** - Code is available for security review

## Support

- 📖 **Documentation**: Check the [DEPLOYMENT.md](DEPLOYMENT.md) for detailed installation instructions
- 🐛 **Issues**: Report bugs via [GitHub Issues](../../issues)
- 💡 **Feature Requests**: Suggest improvements via [GitHub Issues](../../issues)
- 📝 **Logs**: Check `%LOCALAPPDATA%\PublicIPWatcher\app.log` for troubleshooting

## Changelog

### Version 1.0.0
- Initial release
- System tray integration
- Automatic IP monitoring
- Change notifications
- Windows startup integration
- Configurable check intervals
- Comprehensive logging

---

**Made with ❤️ for Windows users who need to monitor their public IP address**
