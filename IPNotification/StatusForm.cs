using System;
using System.Drawing;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IPNotification
{
    /// <summary>
    /// Status form that displays current IP information and allows configuration
    /// </summary>
    public partial class StatusForm : Form
    {
        private readonly TrayAppContext _context;
        private Label _ipLabel;
        private Label _lastChangeLabel;
        private Label _nextCheckLabel;
        private NumericUpDown _intervalUpDown;
        private Button _checkNowButton;
        private Button _copyHistoryButton;

        public StatusForm(TrayAppContext context)
        {
            _context = context;
            InitializeComponent();
            SetupControls();
        }

        private void SetupControls()
        {
            // Form properties
            Text = "PublicIPWatcher Status";
            Size = new Size(350, 250);
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;
            StartPosition = FormStartPosition.CenterScreen;
            ShowInTaskbar = false;

            // Create controls
            var mainPanel = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 2,
                RowCount = 6,
                Padding = new Padding(10)
            };

            // IP Address
            mainPanel.Controls.Add(new Label { Text = "Current IP:", TextAlign = ContentAlignment.MiddleRight }, 0, 0);
            _ipLabel = new Label { Text = "Unknown", AutoSize = true, Font = new Font(Font, FontStyle.Bold) };
            mainPanel.Controls.Add(_ipLabel, 1, 0);

            // Last Change
            mainPanel.Controls.Add(new Label { Text = "Last Change:", TextAlign = ContentAlignment.MiddleRight }, 0, 1);
            _lastChangeLabel = new Label { Text = "Never", AutoSize = true };
            mainPanel.Controls.Add(_lastChangeLabel, 1, 1);

            // Next Check
            mainPanel.Controls.Add(new Label { Text = "Next Check:", TextAlign = ContentAlignment.MiddleRight }, 0, 2);
            _nextCheckLabel = new Label { Text = "Calculating...", AutoSize = true };
            mainPanel.Controls.Add(_nextCheckLabel, 1, 2);

            // Check Interval
            mainPanel.Controls.Add(new Label { Text = "Check Interval (min):", TextAlign = ContentAlignment.MiddleRight }, 0, 3);
            _intervalUpDown = new NumericUpDown 
            { 
                Minimum = 1, 
                Maximum = 1440, // 24 hours
                Value = Properties.Settings.Default.CheckIntervalMinutes,
                Width = 80
            };
            _intervalUpDown.ValueChanged += OnIntervalChanged;
            mainPanel.Controls.Add(_intervalUpDown, 1, 3);

            // Buttons
            var buttonPanel = new FlowLayoutPanel
            {
                FlowDirection = FlowDirection.LeftToRight,
                AutoSize = true,
                WrapContents = false
            };

            _checkNowButton = new Button { Text = "Check Now", AutoSize = true };
            _checkNowButton.Click += async (s, e) => await OnCheckNowClick();
            buttonPanel.Controls.Add(_checkNowButton);

            _copyHistoryButton = new Button { Text = "Copy History", AutoSize = true };
            _copyHistoryButton.Click += OnCopyHistoryClick;
            buttonPanel.Controls.Add(_copyHistoryButton);

            mainPanel.Controls.Add(buttonPanel, 1, 4);

            // Set column styles
            mainPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 40));
            mainPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 60));

            Controls.Add(mainPanel);

            // Handle form closing to hide instead of dispose
            FormClosing += (s, e) =>
            {
                if (e.CloseReason == CloseReason.UserClosing)
                {
                    e.Cancel = true;
                    Hide();
                }
            };
        }

        public void UpdateStatus(string? currentIp, DateTime? lastChangeTime, int remainingSeconds)
        {
            if (InvokeRequired)
            {
                Invoke(() => UpdateStatus(currentIp, lastChangeTime, remainingSeconds));
                return;
            }

            _ipLabel.Text = currentIp ?? "Unknown";
            _lastChangeLabel.Text = lastChangeTime?.ToString("yyyy-MM-dd HH:mm:ss") ?? "Never";
            UpdateCountdown(remainingSeconds);
        }

        public void UpdateCountdown(int remainingSeconds)
        {
            if (InvokeRequired)
            {
                Invoke(() => UpdateCountdown(remainingSeconds));
                return;
            }

            var timeSpan = TimeSpan.FromSeconds(remainingSeconds);
            _nextCheckLabel.Text = $"{timeSpan.Minutes:D2}:{timeSpan.Seconds:D2}";
        }

        private void OnIntervalChanged(object? sender, EventArgs e)
        {
            var newInterval = (int)_intervalUpDown.Value;
            Properties.Settings.Default.CheckIntervalMinutes = newInterval;
            Properties.Settings.Default.Save();
            
            _context.UpdateTimerInterval();
        }

        private async Task OnCheckNowClick()
        {
            _checkNowButton.Enabled = false;
            _checkNowButton.Text = "Checking...";
            
            try
            {
                // Trigger immediate check through context
                await Task.Run(async () => await _context.CheckNow());
            }
            finally
            {
                _checkNowButton.Enabled = true;
                _checkNowButton.Text = "Check Now";
            }
        }

        private void OnCopyHistoryClick(object? sender, EventArgs e)
        {
            try
            {
                var history = _context.GetLastLogLines();
                Clipboard.SetText(history);
                MessageBox.Show("Log history copied to clipboard!", "Copy History", 
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to copy history: {ex.Message}", "Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
