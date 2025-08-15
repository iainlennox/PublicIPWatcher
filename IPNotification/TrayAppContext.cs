using System;
using System.Drawing;
using System.Threading.Tasks;
using System.Windows.Forms;
using IPNotification.Properties;
using Microsoft.Win32;

namespace IPNotification
{
    /// <summary>
    /// Main application context that manages the system tray icon and application lifecycle
    /// </summary>
    public class TrayAppContext : ApplicationContext
    {
        private readonly NotifyIcon _notifyIcon;
        private readonly System.Windows.Forms.Timer _checkTimer;
        private readonly System.Windows.Forms.Timer _countdownTimer;
        private StatusForm? _statusForm;
        private string? _currentIp;
        private DateTime? _lastChangeTime;
        private int _remainingSeconds;
        private bool _hasShownOfflineNotification;

        public TrayAppContext()
        {
            Logging.Log("PublicIPWatcher starting up");

            // Initialize tray icon
            _notifyIcon = new NotifyIcon
            {
                Icon = GetTrayIcon(),
                Text = "PublicIPWatcher - Loading...",
                Visible = true,
                ContextMenuStrip = CreateContextMenu()
            };

            // Double-click to show status
            _notifyIcon.DoubleClick += (s, e) => ShowStatus();

            // Initialize check timer
            _checkTimer = new System.Windows.Forms.Timer();
            _checkTimer.Tick += async (s, e) => await OnTimerTick();
            
            // Initialize countdown timer (updates every second)
            _countdownTimer = new System.Windows.Forms.Timer 
            { 
                Interval = 1000,
                Enabled = true
            };
            _countdownTimer.Tick += OnCountdownTick;
            
            // Set initial interval and start
            UpdateTimerInterval();
            
            // Initial check
            _ = Task.Run(async () => await CheckIpAddress(isInitialCheck: true));
        }

        private Icon GetTrayIcon()
        {
            // Use a simple system icon for now
            return SystemIcons.Information;
        }

        private ContextMenuStrip CreateContextMenu()
        {
            var menu = new ContextMenuStrip();

            menu.Items.Add("Show Status", null, (s, e) => ShowStatus());
            menu.Items.Add("Copy IP", null, async (s, e) => await CopyIpToClipboard());
            menu.Items.Add("Check Now", null, async (s, e) => await CheckNow());
            menu.Items.Add("-"); // Separator
            
            var startWithWindowsItem = new ToolStripMenuItem("Start with Windows")
            {
                Checked = Settings.Default.StartWithWindows,
                CheckOnClick = true
            };
            startWithWindowsItem.Click += OnStartWithWindowsToggle;
            menu.Items.Add(startWithWindowsItem);
            
            menu.Items.Add("-"); // Separator
            menu.Items.Add("Open Log Folder", null, (s, e) => OpenLogFolder());
            menu.Items.Add("-"); // Separator
            menu.Items.Add("Exit", null, (s, e) => ExitApplication());

            return menu;
        }

        private void ShowStatus()
        {
            if (_statusForm == null || _statusForm.IsDisposed)
            {
                _statusForm = new StatusForm(this);
            }

            _statusForm.UpdateStatus(_currentIp, _lastChangeTime, _remainingSeconds);
            
            if (!_statusForm.Visible)
            {
                _statusForm.Show();
            }
            
            _statusForm.WindowState = FormWindowState.Normal;
            _statusForm.BringToFront();
            _statusForm.Activate();
        }

        private async Task CopyIpToClipboard()
        {
            if (string.IsNullOrEmpty(_currentIp))
            {
                await CheckIpAddress();
            }

            if (!string.IsNullOrEmpty(_currentIp))
            {
                try
                {
                    Clipboard.SetText(_currentIp);
                    _notifyIcon.ShowBalloonTip(2000, "IP Copied", $"Copied {_currentIp} to clipboard", ToolTipIcon.Info);
                }
                catch (Exception ex)
                {
                    Logging.Log($"Failed to copy IP to clipboard: {ex.Message}");
                }
            }
            else
            {
                _notifyIcon.ShowBalloonTip(3000, "IP Unknown", "Unable to determine current IP address", ToolTipIcon.Warning);
            }
        }

        public async Task CheckNow()
        {
            await CheckIpAddress();
            _statusForm?.UpdateStatus(_currentIp, _lastChangeTime, _remainingSeconds);
        }

        private void OnStartWithWindowsToggle(object? sender, EventArgs e)
        {
            if (sender is ToolStripMenuItem menuItem)
            {
                var newValue = menuItem.Checked;
                Settings.Default.StartWithWindows = newValue;
                Settings.Default.Save();
                
                UpdateStartupRegistration(newValue);
            }
        }

        private void UpdateStartupRegistration(bool enable)
        {
            try
            {
                const string keyName = @"Software\Microsoft\Windows\CurrentVersion\Run";
                const string valueName = "PublicIPWatcher";
                
                using var key = Registry.CurrentUser.OpenSubKey(keyName, true);
                if (key != null)
                {
                    if (enable)
                    {
                        var exePath = Application.ExecutablePath;
                        key.SetValue(valueName, exePath);
                        Logging.Log("Added to Windows startup");
                    }
                    else
                    {
                        key.DeleteValue(valueName, false);
                        Logging.Log("Removed from Windows startup");
                    }
                }
            }
            catch (Exception ex)
            {
                Logging.Log($"Failed to update startup registration: {ex.Message}");
                
                // Update the menu to reflect the actual state
                if (_notifyIcon.ContextMenuStrip?.Items["Start with Windows"] is ToolStripMenuItem menuItem)
                {
                    menuItem.Checked = Settings.Default.StartWithWindows;
                }
            }
        }

        private void OpenLogFolder()
        {
            try
            {
                System.Diagnostics.Process.Start("explorer.exe", Logging.LogDirectory);
            }
            catch (Exception ex)
            {
                Logging.Log($"Failed to open log folder: {ex.Message}");
            }
        }

        private async Task OnTimerTick()
        {
            await CheckIpAddress();
            _statusForm?.UpdateStatus(_currentIp, _lastChangeTime, _remainingSeconds);
            
            // Reset countdown
            _remainingSeconds = Settings.Default.CheckIntervalMinutes * 60;
        }

        private void OnCountdownTick(object? sender, EventArgs e)
        {
            if (_remainingSeconds > 0)
            {
                _remainingSeconds--;
                _statusForm?.UpdateCountdown(_remainingSeconds);
            }
        }

        private async Task CheckIpAddress(bool isInitialCheck = false)
        {
            try
            {
                var newIp = await IpFetcher.GetPublicIpAsync();
                
                if (newIp != null)
                {
                    _hasShownOfflineNotification = false;
                    
                    var previousIp = _currentIp;
                    _currentIp = newIp;
                    
                    // Update tooltip
                    _notifyIcon.Text = $"PublicIPWatcher - IP: {_currentIp}";
                    
                    // Check for changes
                    if (!isInitialCheck && previousIp != null && previousIp != _currentIp)
                    {
                        _lastChangeTime = DateTime.Now;
                        
                        // Show balloon notification
                        _notifyIcon.ShowBalloonTip(5000, "Public IP Changed", 
                            $"Old: {previousIp} ? New: {_currentIp}", ToolTipIcon.Info);
                        
                        // Log the change
                        Logging.Log($"IP changed from {previousIp} to {_currentIp}");
                    }
                    else if (isInitialCheck)
                    {
                        Logging.Log($"Initial IP detected: {_currentIp}");
                    }
                    
                    // Update settings
                    Settings.Default.LastKnownIp = _currentIp;
                    Settings.Default.Save();
                }
                else
                {
                    // Failed to get IP
                    _notifyIcon.Text = "PublicIPWatcher - IP: Unknown";
                    
                    if (!_hasShownOfflineNotification)
                    {
                        _notifyIcon.ShowBalloonTip(5000, "Connection Issue", 
                            "Unable to reach IP service", ToolTipIcon.Warning);
                        _hasShownOfflineNotification = true;
                    }
                }
            }
            catch (Exception ex)
            {
                Logging.Log($"Error checking IP address: {ex.Message}");
            }
        }

        public void UpdateTimerInterval()
        {
            var intervalMinutes = Settings.Default.CheckIntervalMinutes;
            _checkTimer.Interval = intervalMinutes * 60 * 1000; // Convert to milliseconds
            _remainingSeconds = intervalMinutes * 60;
            
            if (!_checkTimer.Enabled)
            {
                _checkTimer.Start();
            }
            
            Logging.Log($"Timer interval updated to {intervalMinutes} minutes");
        }

        public string GetLastLogLines() => Logging.GetLastLogLines(10);

        private void ExitApplication()
        {
            Logging.Log("PublicIPWatcher shutting down");
            
            _checkTimer?.Stop();
            _countdownTimer?.Stop();
            _notifyIcon?.Dispose();
            _statusForm?.Close();
            
            IpFetcher.Dispose();
            
            ExitThread();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _checkTimer?.Dispose();
                _countdownTimer?.Dispose();
                _notifyIcon?.Dispose();
                _statusForm?.Dispose();
            }
            
            base.Dispose(disposing);
        }
    }
}