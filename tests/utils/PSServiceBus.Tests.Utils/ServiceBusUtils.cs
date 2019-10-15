using System;
using System.Threading.Tasks;
using System.Collections.Generic;
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
    }
}
