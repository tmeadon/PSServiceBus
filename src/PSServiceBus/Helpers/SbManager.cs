using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Exceptions;
using PSServiceBus.Enums;

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
            this.GetTopicByName(TopicName);

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
            this.GetTopicByName(TopicName);

            return managementClient.GetSubscriptionsAsync(TopicName).Result;
        }

        public QueueRuntimeInfo GetQueueRuntimeInfo(string QueueName)
        {
            this.GetQueueByName(QueueName);

            return managementClient.GetQueueRuntimeInfoAsync(QueueName).Result; 
        }

        public SubscriptionRuntimeInfo GetSubscriptionRuntimeInfo(string TopicName, string SubscriptionName)
        {
            this.GetSubscriptionByName(TopicName, SubscriptionName);

            return managementClient.GetSubscriptionRuntimeInfoAsync(TopicName, SubscriptionName).Result;
        }

        public bool QueueOrTopicExists(string entityPath, SbEntityTypes entityType)
        {
            switch (entityType)
            {
                case SbEntityTypes.Queue:
                    try
                    {
                        this.GetQueueByName(entityPath);
                        return true;
                    }
                    catch
                    {
                        return false;
                    }
                case SbEntityTypes.Topic:
                    try
                    {
                        this.GetTopicByName(entityPath);
                        return true;
                    }
                    catch
                    {
                        return false;
                    }
                default:
                    return false;
            }
        }

        public bool SubscriptionExists(string TopicName, string SubscriptionName)
        {
            try
            {
                this.GetSubscriptionByName(TopicName, SubscriptionName);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public string BuildSubscriptionPath(string TopicName, string SubscriptionName)
        {
            return String.Format("{0}/Subscription/{1}", TopicName, SubscriptionName);
        }
    }
}
