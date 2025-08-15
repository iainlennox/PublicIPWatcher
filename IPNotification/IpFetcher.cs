using System;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace IPNotification
{
    /// <summary>
    /// Static class for fetching public IP address with retry logic and fallback endpoints
    /// </summary>
    public static class IpFetcher
    {
        private static readonly HttpClient _httpClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(5)
        };

        private static readonly string[] _endpoints = 
        {
            "https://api.ipify.org?format=text",
            "https://ifconfig.me/ip"
        };

        /// <summary>
        /// Gets the public IP address with exponential backoff and multiple endpoints
        /// </summary>
        /// <returns>The public IP address as a string, or null if all attempts failed</returns>
        public static async Task<string?> GetPublicIpAsync()
        {
            const int maxRetries = 3;
            
            foreach (var endpoint in _endpoints)
            {
                for (int retry = 0; retry < maxRetries; retry++)
                {
                    try
                    {
                        var response = await _httpClient.GetStringAsync(endpoint);
                        var trimmedIp = response.Trim();
                        
                        // Validate the IP address
                        if (IPAddress.TryParse(trimmedIp, out var validIp))
                        {
                            Logging.Log($"Successfully fetched IP: {trimmedIp} from {endpoint}");
                            return trimmedIp;
                        }
                        
                        Logging.Log($"Invalid IP format received from {endpoint}: {trimmedIp}");
                    }
                    catch (HttpRequestException ex)
                    {
                        Logging.Log($"HTTP error on attempt {retry + 1} for {endpoint}: {ex.Message}");
                    }
                    catch (TaskCanceledException ex)
                    {
                        Logging.Log($"Timeout on attempt {retry + 1} for {endpoint}: {ex.Message}");
                    }
                    catch (Exception ex)
                    {
                        Logging.Log($"Unexpected error on attempt {retry + 1} for {endpoint}: {ex.Message}");
                    }

                    // Exponential backoff: wait 1s, 2s, 4s
                    if (retry < maxRetries - 1)
                    {
                        await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, retry)));
                    }
                }
            }

            Logging.Log("All IP fetch attempts failed");
            return null;
        }

        /// <summary>
        /// Dispose the static HttpClient when the application shuts down
        /// </summary>
        public static void Dispose()
        {
            _httpClient?.Dispose();
        }
    }
}