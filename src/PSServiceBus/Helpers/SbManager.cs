using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Azure.ServiceBus.Management;

namespace PSServiceBus.Helpers
{
    public class SbManager: ISbManager
    {
        private readonly ManagementClient managementClient;

        public SbManager(string NamespaceConnectionString)
        {
            this.managementClient = new ManagementClient(NamespaceConnectionString);
        }

        public QueueDescription GetQueueByName(string QueueName)
        {
            return managementClient.GetQueueAsync(QueueName).Result;
        }

        public IList<QueueDescription> GetAllQueues()
        {
            return managementClient.GetQueuesAsync().Result;
        }

        public TopicDescription GetTopicByName(string TopicName)
        {
            return managementClient.GetTopicAsync(TopicName).Result;
        }

        public IList<TopicDescription> GetAllTopics()
        {
            return managementClient.GetTopicsAsync().Result;
        }

        public SubscriptionDescription GetSubscriptionByName(string TopicName, string SubscriptionName)
        {
            return managementClient.GetSubscriptionAsync(TopicName, SubscriptionName).Result;
        }

        public IList<SubscriptionDescription> GetAllSubscriptions(string TopicName)
        {
            return managementClient.GetSubscriptionsAsync(TopicName).Result;
        }

        public QueueRuntimeInfo GetQueueRuntimeInfo(string QueueName)
        {
            return managementClient.GetQueueRuntimeInfoAsync(QueueName).Result;
        }

        public SubscriptionRuntimeInfo GetSubscriptionRuntimeInfo(string TopicName, string SubscriptionName)
        {
            return managementClient.GetSubscriptionRuntimeInfoAsync(TopicName, SubscriptionName).Result;
        }
    }
}
