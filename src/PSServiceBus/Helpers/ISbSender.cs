using Microsoft.Azure.ServiceBus.Core;

namespace PSServiceBus.Helpers
{
    public interface ISbSender
    {
        MessageSender MessageSender { get; set; }

        void SendMessage(string MessageBody);
    }
}
