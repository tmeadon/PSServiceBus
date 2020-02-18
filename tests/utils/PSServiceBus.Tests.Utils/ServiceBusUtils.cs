using System;
using System.Text;
using System.Collections.Generic;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using Microsoft.Azure.ServiceBus.Management;

namespace PSServiceBus.Tests.Utils
{
    public class ServiceBusUtils
    {
        public string NamespaceConnectionString;

        private readonly ManagementClient managementClient;

        public ServiceBusUtils (string NamespaceConnectionString)
        {
            this.NamespaceConnectionString = NamespaceConnectionString;
            this.managementClient = new ManagementClient(NamespaceConnectionString);
        }

        public void CreateQueue(string QueueName)
        {
            this.managementClient.CreateQueueAsync(QueueName);
            bool exists = false;
            while (!exists)
            {
                exists = this.managementClient.QueueExistsAsync(QueueName).Result;
            }
        }

        public void CreateTopic(string TopicName)
        {
            this.managementClient.CreateTopicAsync(TopicName);
            bool exists = false;
            while (!exists)
            {
                exists = this.managementClient.TopicExistsAsync(TopicName).Result;
            }
        }

        public void CreateSubscription(string TopicName, string SubscriptionName)
        {
            this.managementClient.CreateSubscriptionAsync(TopicName, SubscriptionName);
            bool exists = false;
            while (!exists)
            {
                exists = this.managementClient.SubscriptionExistsAsync(TopicName, SubscriptionName).Result;
            }
        }

        public List<string> CreateQueues(int NumberToCreate)
        {
            List<string> queues = new List<string>();

            for (int i = 0; i < NumberToCreate; i++)
            {
                var guid = Guid.NewGuid().ToString();
                this.CreateQueue(guid);
                queues.Add(guid);
            }

            return queues;
        }

        public List<string> CreateTopics(int NumberToCreate)
        {
            List<string> topics = new List<string>();

            for (int i = 0; i < NumberToCreate; i++)
            {
                var guid = Guid.NewGuid().ToString();
                this.CreateTopic(guid);
                topics.Add(guid);
            }

            return topics;
        }

        public List<string> CreateSubscriptions(string TopicName, int NumberToCreate)
        {
            List<string> subscriptions = new List<string>();

            for (int i = 0; i < NumberToCreate; i++)
            {
                var guid = Guid.NewGuid().ToString();
                this.CreateSubscription(TopicName, guid);
                subscriptions.Add(guid);
            }

            return subscriptions;
        }

        public void RemoveQueue(string QueueName)
        {
            this.managementClient.DeleteQueueAsync(QueueName);
        }

        public void RemoveTopic(string TopicName)
        {
            this.managementClient.DeleteTopicAsync(TopicName);
        }

        public IList<QueueDescription> GetAllQueues()
        {
            return this.managementClient.GetQueuesAsync().Result;
        }

        public void SendTestMessage(string entityName)
        {
            MessageSender sender = new MessageSender(this.NamespaceConnectionString, entityName, null);
            sender.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;
            var guid = Guid.NewGuid().ToString();
            byte[] body = Encoding.UTF8.GetBytes("{ 'id': '" + guid + "' }");
            Message message = new Message(body);
            sender.SendAsync(message);
        }

        public void ScheduleTestMessage(string entityName, DateTime enqueueDatetimeUtc)
        {
            MessageSender sender = new MessageSender(this.NamespaceConnectionString, entityName, null);
            sender.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;
            var guid = Guid.NewGuid().ToString();
            byte[] body = Encoding.UTF8.GetBytes("{ 'id': '" + guid + "' }");
            Message message = new Message(body);
            sender.ScheduleMessageAsync(message, enqueueDatetimeUtc);
        }

        public string ReceiveAndCompleteAMessage(string entityName)
        {
            MessageReceiver receiver = new MessageReceiver(this.NamespaceConnectionString, entityName);
            receiver.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;
            Message message = receiver.ReceiveAsync().Result;
            receiver.DeadLetterAsync(message.SystemProperties.LockToken);
            string bodyStr = Encoding.UTF8.GetString(message.Body);
            return bodyStr;
        }

        public void ReceiveAndDeadLetterAMessage(string entityName)
        {
            MessageReceiver receiver = new MessageReceiver(this.NamespaceConnectionString, entityName);
            receiver.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;
            Message message = receiver.ReceiveAsync().Result;
            receiver.DeadLetterAsync(message.SystemProperties.LockToken);
        }

        public string BuildSubscriptionPath(string TopicName, string SubscriptionName)
        {
            return EntityNameHelper.FormatSubscriptionPath(TopicName, SubscriptionName);
        }

        public QueueRuntimeInfo GetQueueRuntimeInfo(string queueName)
        {
            return this.managementClient.GetQueueRuntimeInfoAsync(queueName).Result;
        }

        public SubscriptionRuntimeInfo GetSubscriptionRuntimeInfo(string topicName, string subscriptionName)
        {
            return this.managementClient.GetSubscriptionRuntimeInfoAsync(topicName, subscriptionName).Result;
        }

        public TopicRuntimeInfo GetTopicRuntimeInfo(string topicName)
        {
            return this.managementClient.GetTopicRuntimeInfoAsync(topicName).Result;
        }

        public void SendMessage(string entityName, string messageBody)
        {
            MessageSender messageSender = new MessageSender(this.NamespaceConnectionString, entityName);
            messageSender.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;
            byte[] body = Encoding.UTF8.GetBytes(messageBody);
            Message message = new Message(body);
            messageSender.SendAsync(message);
        }

        public void SendMessagesInBatch(string entityName, string[] messages)
        {
            MessageSender messageSender = new MessageSender(this.NamespaceConnectionString, entityName);
            messageSender.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;

            IList<Message> messagesToSend = new List<Message>();

            foreach (var messageBody in messages)
            {
                byte[] body = Encoding.UTF8.GetBytes(messageBody);
                messagesToSend.Add(new Message(body));
            }

            var temp = messageSender.SendAsync(messagesToSend);
            temp.Wait();
        }

        public long GetMessageBatchSize(string[] Messages)
        {
            long batchSize = 0;

            for (int i = 0; i < Messages.Length; i++)
            {
                byte[] body = Encoding.UTF8.GetBytes(Messages[i]);
                Message message = new Message(body);
                batchSize += message.Size;
            }
            
            return batchSize;
        }

        public string GetNamespaceSku()
        {
            return this.managementClient.GetNamespaceInfoAsync().Result.MessagingSku.ToString();
        }
    }
}
