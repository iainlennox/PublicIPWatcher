using System;
using System.Threading;
using System.Windows.Forms;

namespace IPNotification
{
    internal static class Program
    {
        private static Mutex? _mutex;
        private const string MUTEX_NAME = "PublicIPWatcher_SingleInstance";

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // Check for single instance
            _mutex = new Mutex(true, MUTEX_NAME, out bool isNewInstance);
            
            if (!isNewInstance)
            {
                // Another instance is running
                MessageBox.Show("PublicIPWatcher is already running. Check the system tray.", 
                    "PublicIPWatcher", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();

            try
            {
                // Run the tray application context
                Application.Run(new TrayAppContext());
            }
            finally
            {
                _mutex?.ReleaseMutex();
                _mutex?.Dispose();
            }
        }
    }
}