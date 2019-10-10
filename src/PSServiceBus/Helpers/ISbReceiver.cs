using System.Collections.Generic;
using Microsoft.Azure.ServiceBus.Core;
using PSServiceBus.Outputs;

namespace PSServiceBus.Helpers
{
    public interface ISbReceiver
    {
        IList<SbMessage> PeekMessages(int NumberOfMessages);

        IList<SbMessage> ReceiveAndDelete(int NumberOfMessages);
    }
}
