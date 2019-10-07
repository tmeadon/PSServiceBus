using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management.Automation;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;
using PSServiceBus.Outputs;

namespace PSServiceBus
{
    [Cmdlet(VerbsCommon.Get, "SbTopic")]
    [OutputType(typeof(SbTopic))]
    public class GetSbTopic: Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = false)]
        public string TopicNameStartsWith { get; set; }

        protected override void ProcessRecord()
        {
            IEnumerable<TopicDescription> topics;
            NamespaceManager namespaceManager = NamespaceManager.CreateFromConnectionString(NamespaceConnectionString);

            if (TopicNameStartsWith != null)
            {
                topics = namespaceManager.GetTopics(String.Format($"startswith(path, '" + TopicNameStartsWith + "') eq true"));
            }
            else
            {
                topics = namespaceManager.GetTopics();
            }
            
            foreach (var topic in topics)
            {
                IEnumerable<SubscriptionDescription> subscriptions = namespaceManager.GetSubscriptions(topic.Path);

                WriteObject(new SbTopic
                {
                    TopicName = topic.Path,
                    Subscriptions = subscriptions.Select(sub => sub.Name).ToList()
                });
            }
        }
    }
}
