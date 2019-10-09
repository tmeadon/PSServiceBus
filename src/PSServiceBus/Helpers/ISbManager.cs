﻿using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Azure.ServiceBus.Management;

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
    }
}