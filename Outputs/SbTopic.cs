using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSServiceBus.Outputs
{
    class SbTopic
    {
        public string TopicName { get; set; }
        public List<string> Subscriptions { get; set; }
    }
}
