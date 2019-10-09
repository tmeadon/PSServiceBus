using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Exceptions;

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
            try
            {
                return managementClient.GetQueueAsync(QueueName).Result;
            }
            catch
            {
                throw new NonExistentEntityException(String.Format("Queue {0} does not exist", QueueName));
            }
        }

        public IList<QueueDescription> GetAllQueues()
        {
            return managementClient.GetQueuesAsync().Result;
        }

        public TopicDescription GetTopicByName(string TopicName)
        {
            try
            {
                return managementClient.GetTopicAsync(TopicName).Result;
            }
            catch
            {
                throw new NonExistentEntityException(String.Format("Topic {0} does not exist", TopicName));
            }
        }

        public IList<TopicDescription> GetAllTopics()
        {
            return managementClient.GetTopicsAsync().Result;
        }

        public SubscriptionDescription GetSubscriptionByName(string TopicName, string SubscriptionName)
        {
            var topic = this.GetTopicByName(TopicName);

            try
            {
                return managementClient.GetSubscriptionAsync(TopicName, SubscriptionName).Result;
            }
            catch
            {
                throw new NonExistentEntityException(String.Format("Subscription {0} does not exist in topic {1}", SubscriptionName, TopicName));
            }
        }

        public IList<SubscriptionDescription> GetAllSubscriptions(string TopicName)
        {
            return managementClient.GetSubscriptionsAsync(TopicName).Result;
        }

        public QueueRuntimeInfo GetQueueRuntimeInfo(string QueueName)
        {
            var queue = this.GetQueueByName(QueueName);

            return managementClient.GetQueueRuntimeInfoAsync(QueueName).Result; 
        }

        public SubscriptionRuntimeInfo GetSubscriptionRuntimeInfo(string TopicName, string SubscriptionName)
        {
            var sub = this.GetSubscriptionByName(TopicName, SubscriptionName);

            return managementClient.GetSubscriptionRuntimeInfoAsync(TopicName, SubscriptionName).Result;
        }
    }
}
