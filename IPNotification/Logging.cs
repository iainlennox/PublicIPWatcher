using System;
using System.IO;
using System.Text;

namespace IPNotification
{
    /// <summary>
    /// Simple rolling file logger for the application
    /// </summary>
    public static class Logging
    {
        private static readonly string _logDirectory;
        private static readonly string _logFilePath;
        private static readonly object _lockObject = new object();
        private const int MaxLogSizeBytes = 256 * 1024; // 256 KB

        static Logging()
        {
            _logDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "PublicIPWatcher");
            _logFilePath = Path.Combine(_logDirectory, "app.log");
            
            // Ensure directory exists
            Directory.CreateDirectory(_logDirectory);
        }

        /// <summary>
        /// Logs a message to the application log file
        /// </summary>
        /// <param name="message">The message to log</param>
        public static void Log(string message)
        {
            try
            {
                lock (_lockObject)
                {
                    var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                    var logEntry = $"[{timestamp}] {message}{Environment.NewLine}";
                    
                    // Check if log needs trimming
                    if (File.Exists(_logFilePath))
                    {
                        var fileInfo = new FileInfo(_logFilePath);
                        if (fileInfo.Length > MaxLogSizeBytes)
                        {
                            TrimLogFile();
                        }
                    }

                    // Append the log entry
                    File.AppendAllText(_logFilePath, logEntry, Encoding.UTF8);
                }
            }
            catch (Exception ex)
            {
                // Fail silently - don't let logging errors crash the app
                System.Diagnostics.Debug.WriteLine($"Logging error: {ex.Message}");
            }
        }

        /// <summary>
        /// Gets the log directory path
        /// </summary>
        public static string LogDirectory => _logDirectory;

        /// <summary>
        /// Gets the last N lines from the log file
        /// </summary>
        /// <param name="lineCount">Number of lines to retrieve</param>
        /// <returns>The last N lines as a string</returns>
        public static string GetLastLogLines(int lineCount = 10)
        {
            try
            {
                lock (_lockObject)
                {
                    if (!File.Exists(_logFilePath))
                        return "No log entries found.";

                    var lines = File.ReadAllLines(_logFilePath);
                    var startIndex = Math.Max(0, lines.Length - lineCount);
                    var lastLines = new string[Math.Min(lineCount, lines.Length)];
                    
                    Array.Copy(lines, startIndex, lastLines, 0, lastLines.Length);
                    
                    return string.Join(Environment.NewLine, lastLines);
                }
            }
            catch (Exception ex)
            {
                return $"Error reading log: {ex.Message}";
            }
        }

        private static void TrimLogFile()
        {
            try
            {
                var lines = File.ReadAllLines(_logFilePath);
                var keepLines = lines.Length / 2; // Keep the last half
                
                if (keepLines > 0)
                {
                    var linesToKeep = new string[keepLines];
                    Array.Copy(lines, lines.Length - keepLines, linesToKeep, 0, keepLines);
                    
                    File.WriteAllLines(_logFilePath, linesToKeep, Encoding.UTF8);
                    Log("Log file trimmed");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Log trim error: {ex.Message}");
            }
        }
    }
}