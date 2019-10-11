using System.Collections.Generic;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Enums;

namespace PSServiceBus.Helpers
{
    public interface ISbManager
    {
        QueueDescription GetQueueByName(string QueueName);

        IList<QueueDescription> GetAllQueues();

        TopicDescription GetTopicByName(string TopicName);

        IList<TopicDescription> GetAllTopics();

        SubscriptionDescription GetSubscriptionByName(string TopicName, string SubscriptionName);

        IList<SubscriptionDescription> GetAllSubscriptions(string TopicName);

        QueueRuntimeInfo GetQueueRuntimeInfo(string QueueName);

        SubscriptionRuntimeInfo GetSubscriptionRuntimeInfo(string TopicName, string SubscriptionName);

        bool QueueOrTopicExists(string entityPath, SbEntityTypes entityType);

        bool SubscriptionExists(string TopicName, string SubscriptionName);

        string BuildSubscriptionPath(string TopicName, string SubscriptionName);

        string BuildDeadLetterPath(string EntityPath);
    }
}
