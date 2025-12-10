using System.Text;
using System.Text.Json;
using Azure;
using Azure.AI.Inference;
using System.Threading;

namespace ZavaStorefront.Services
{
    public class ChatService
    {
        private readonly ChatCompletionsClient _client;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ChatService> _logger;
        private readonly string _deploymentName;

        public ChatService(IConfiguration configuration, ILogger<ChatService> logger)
        {
            _configuration = configuration;
            _logger = logger;

            var endpoint = _configuration["FoundrySettings:Phi4EndpointUrl"];
            var apiKey = _configuration["FoundrySettings:ApiKey"];
            _deploymentName = _configuration["FoundrySettings:DeploymentName"] ?? "Phi-4";

            if (string.IsNullOrEmpty(endpoint) || string.IsNullOrEmpty(apiKey))
            {
                throw new InvalidOperationException("Foundry settings are not configured properly");
            }

            _client = new ChatCompletionsClient(
                new Uri(endpoint),
                new AzureKeyCredential(apiKey)
            );
        }

        public async Task<string> SendMessageAsync(string userMessage)
        {
            try
            {
                _logger.LogInformation("Sending message to Azure AI Foundry deployment: {DeploymentName}", _deploymentName);

                var requestOptions = new ChatCompletionsOptions
                {
                    Messages =
                    {
                        new ChatRequestUserMessage(userMessage)
                    },
                    MaxTokens = 800,
                    Temperature = 0.7f,
                    Model = _deploymentName
                };

                var response = await _client.CompleteAsync(requestOptions);

                if (response?.Value != null && response.Value.Content != null)
                {
                    return response.Value.Content ?? "No response from AI.";
                }

                _logger.LogWarning("No content returned from Phi4 endpoint");
                return "Error: No response from AI service.";
            }
            catch (RequestFailedException ex)
            {
                _logger.LogError(ex, "Azure AI request failed with status {StatusCode}", ex.Status);
                return $"Error: Unable to get response from AI service. Status: {ex.Status}";
            }
            catch (Exception ex)
            {
                if (IsCriticalException(ex)) throw;
                _logger.LogError(ex, "Unexpected error while communicating with Azure AI Foundry");
                return "Error: An unexpected error occurred. Please try again.";
            }
        }
        private static bool IsCriticalException(Exception ex)
        {
            return ex is OutOfMemoryException
                   || ex is StackOverflowException
                   || ex is AccessViolationException
                   || ex is AppDomainUnloadedException
                   || ex is ThreadAbortException;
        }
    }
}
