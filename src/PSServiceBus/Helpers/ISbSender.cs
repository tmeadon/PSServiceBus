using Microsoft.Azure.ServiceBus.Core;

namespace PSServiceBus.Helpers
{
    public interface ISbSender
    {
        void SendMessage(string MessageBody);
    }
}
