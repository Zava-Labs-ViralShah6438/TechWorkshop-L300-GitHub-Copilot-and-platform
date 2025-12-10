namespace ZavaStorefront.Models
{
    public class ChatMessageRequest
    {
        public string Message { get; set; } = string.Empty;
    }

    public class ChatMessageResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
    }
}
