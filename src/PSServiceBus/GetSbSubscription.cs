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
    [Cmdlet(VerbsCommon.Get, "SbSubscription")]
    [OutputType(typeof(SbSubscription))]
    public class GetSbSubscription : Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = false)]
        public string TopicName { get; set; }

        protected override void ProcessRecord()
        {
            IList<SubscriptionDescription> subscriptions = new List<SubscriptionDescription>();
            ManagementClient managementClient = new ManagementClient(NamespaceConnectionString);

            subscriptions = managementClient.GetSubscriptionsAsync(TopicName).Result;

            foreach (var sub in subscriptions)
            {
                SubscriptionRuntimeInfo subscriptionRuntimeInfo = managementClient.GetSubscriptionRuntimeInfoAsync(TopicName, sub.SubscriptionName).Result;

                WriteObject(new SbSubscription
                {
                    Name = sub.SubscriptionName,
                    Topic = sub.TopicPath,
                    ActiveMessages = subscriptionRuntimeInfo.MessageCountDetails.ActiveMessageCount,
                    DeadLetteredMessages = subscriptionRuntimeInfo.MessageCountDetails.DeadLetterMessageCount
                });
            }
        }
    }
}

