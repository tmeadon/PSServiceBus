using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;

namespace PSServiceBus.Cmdlets
{
    [Cmdlet(VerbsCommon.Get, "SbTopic")]
    [OutputType(typeof(SbQueue))]
    public class GetSbTopic : Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = false)]
        public string TopicName { get; set; }

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

