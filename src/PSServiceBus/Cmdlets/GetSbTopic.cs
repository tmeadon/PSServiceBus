using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Gets a topic by name or a list of all topics from an Azure Service Bus Namespace.  Returns the names of the subscriptions in the retrieved topic(s).</para>
    /// <para type="description">Gets a topic by name or a list of all topics from an Azure Service Bus Namespace.  Returns the names of the subscriptions in the retrieved topic(s).</para>
    /// </summary>
    /// <example>
    /// <code>Get-SbTopic -NamespaceConnectionString $namespaceConnectionString -TopicName 'example-topic'</code>
    /// <para>This gets information about a single topic called 'example-topic'.</para>
    /// </example>
    /// <example>
    /// <code>Get-SbTopic -NamespaceConnectionString $namespaceConnectionString</code>
    /// <para>This gets information about all topics.</para>
    /// </example>
    [Cmdlet(VerbsCommon.Get, "SbTopic")]
    [OutputType(typeof(SbTopic))]
    public class GetSbTopic : Cmdlet
    {
        /// <summary>
        /// <para type="description">A connection string with 'Manage' rights for the Azure Service Bus Namespace.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        /// <summary>
        /// <para type="description">The name of the topic to retrieve.  All topics are returned if not specified.</para>
        /// </summary>
        [Parameter(Mandatory = false)]
        public string TopicName { get; set; }

        /// <summary>
        /// Main cmdlet method.
        /// </summary>
        protected override void ProcessRecord()
        {
            SbManager sbManager = new SbManager(NamespaceConnectionString);

            var output = BuildTopicList(sbManager, TopicName);

            foreach (var item in output)
            {
                WriteObject(item);
            }
        }

        private IList<SbTopic> BuildTopicList(ISbManager SbManager, string TopicName)
        {
            IList<SbTopic> result = new List<SbTopic>();
            IList<TopicDescription> topics = new List<TopicDescription>();

            if (TopicName != null)
            {
                topics.Add(SbManager.GetTopicByName(TopicName));
            }
            else
            {
                topics = SbManager.GetAllTopics();
            }

            foreach (var topic in topics)
            {
                IList<SubscriptionDescription> subscriptions = SbManager.GetAllSubscriptions(topic.Path);

                result.Add(new SbTopic
                {
                    TopicName = topic.Path,
                    Subscriptions = subscriptions.Select(sub => sub.SubscriptionName).ToList()
                });
            }

            return result;
        }
    }
}

