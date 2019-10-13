using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;

namespace PSServiceBus.Cmdlets
{
    [Cmdlet(VerbsCommon.Get, "SbSubscription")]
    [OutputType(typeof(SbSubscription))]
    public class GetSbSubscription : Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = true,
                   ValueFromPipelineByPropertyName = true)]
        public string TopicName { get; set; }

        [Parameter(Mandatory = false)]
        public string SubscriptionName { get; set; }

        protected override void ProcessRecord()
        {
            SbManager sbManager = new SbManager(NamespaceConnectionString);

            var output = BuildSubscriptionList(sbManager, TopicName, SubscriptionName);

            foreach (var item in output)
            {
                WriteObject(item);
            }
        }

        private IList<SbSubscription> BuildSubscriptionList(ISbManager sbManager, string TopicName, string SubscriptionName)
        {
            IList<SbSubscription> result = new List<SbSubscription>();
            IList<SubscriptionDescription> subscriptions = new List<SubscriptionDescription>();

            if (SubscriptionName != null)
            {
                subscriptions.Add(sbManager.GetSubscriptionByName(TopicName, SubscriptionName));
            }
            else
            {
                subscriptions = sbManager.GetAllSubscriptions(TopicName);
            }

            foreach (var subscription in subscriptions)
            {
                SubscriptionRuntimeInfo subscriptionRuntimeInfo = sbManager.GetSubscriptionRuntimeInfo(TopicName, subscription.SubscriptionName);

                result.Add(new SbSubscription
                {
                    Name = subscription.SubscriptionName,
                    Topic = subscription.TopicPath,
                    ActiveMessages = subscriptionRuntimeInfo.MessageCountDetails.ActiveMessageCount,
                    DeadLetteredMessages = subscriptionRuntimeInfo.MessageCountDetails.DeadLetterMessageCount
                });
            }

            return result;
        }
    }
}

