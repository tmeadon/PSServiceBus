using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Gets a subscription by name or a list of all subscriptions in an from an Azure Service Bus Topic.  Returns the number of messages in the active and dead letter queues.</para>
    /// <para type="description">Gets a subscription by name or a list of all subscriptions in an from an Azure Service Bus Topic.  Returns the number of messages in the active and dead letter queues.</para>
    /// </summary>
    /// <example>
    /// <code>Get-SbSubscription -NamespaceConnectionString $namespaceConnectionString -TopicName 'example-topic' -SubscriptionName 'example-subscription'</code>
    /// <para>This gets information about a single subscription called 'example-subscription' in a topic called 'example-topic'.</para>
    /// </example>
    /// <example>
    /// <code>Get-SbSubscription -NamespaceConnectionString $namespaceConnectionString -TopicName 'example-topic'</code>
    /// <para>This gets information about all subscriptions in a topic called 'example-topic'.</para>
    /// </example>
    [Cmdlet(VerbsCommon.Get, "SbSubscription")]
    [OutputType(typeof(SbSubscription))]
    public class GetSbSubscription : Cmdlet
    {
        /// <summary>
        /// <para type="description">A connection string with 'Manage' rights for the Azure Service Bus Namespace.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        /// <summary>
        /// <para type="description">Name of the topic to retrieve subscriptions from.</para>
        /// </summary>
        [Parameter(Mandatory = true,
                   ValueFromPipelineByPropertyName = true)]
        public string TopicName { get; set; }

        /// <summary>
        /// <para type="description">Name of a specific subscription to retrieve.</para>
        /// </summary>
        [Parameter(Mandatory = false)]
        public string SubscriptionName { get; set; }

        /// <summary>
        /// Main cmdlet method.
        /// </summary>
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

