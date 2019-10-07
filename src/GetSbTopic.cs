using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;

namespace PSServiceBus
{
    [Cmdlet(VerbsCommon.Get, "SbTopic")]
    [OutputType(typeof(SbQueue))]
    public class GetSbTopic : PSCmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = false)]
        public string TopicName { get; set; }

        protected override void ProcessRecord()
        {
            IList<TopicDescription> topics = new List<TopicDescription>();
            ManagementClient managementClient = new ManagementClient(NamespaceConnectionString);

            if (TopicName != null)
            {
                topics.Add(managementClient.GetTopicAsync(TopicName).Result);  //queues.Where(i => i.Path == QueueName).ToList<QueueDescription>();
            }
            else
            {
                topics = managementClient.GetTopicsAsync().Result;
            }

            foreach (var topic in topics)
            {
                IList<SubscriptionDescription> subscriptions = managementClient.GetSubscriptionsAsync(topic.Path).Result;

                WriteObject(new SbTopic
                {
                    TopicName = topic.Path,
                    Subscriptions = subscriptions.Select(sub => sub.SubscriptionName).ToList()                    
                });
            }
        }
    }
}

