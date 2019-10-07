using System.Collections.Generic;

namespace PSServiceBus.Outputs
{
    class SbTopic
    {
        public string TopicName { get; set; }
        public List<string> Subscriptions { get; set; }
    }
}
