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

        public void RemoveQueue(string QueueName)
        {
            this.managementClient.DeleteQueueAsync(QueueName);
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
    }
}
