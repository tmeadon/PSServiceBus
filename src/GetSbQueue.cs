using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;

namespace PSServiceBus
{
    [Cmdlet(VerbsCommon.Get, "SbQueue")]
    [OutputType(typeof(SbQueue))]
    public class GetSbQueue: PSCmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = false)]
        public string QueueName { get; set; }
        
        protected override void ProcessRecord()
        {
            IList<QueueDescription> queues = new List<QueueDescription>();
            ManagementClient managementClient = new ManagementClient(NamespaceConnectionString);

            if (QueueName != null)
            {
                queues.Add(managementClient.GetQueueAsync(QueueName).Result);  //queues.Where(i => i.Path == QueueName).ToList<QueueDescription>();
            }
            else
            {
                queues = managementClient.GetQueuesAsync().Result;
            }
            
            foreach (var queue in queues)
            {
                QueueRuntimeInfo queueRuntimeInfo = managementClient.GetQueueRuntimeInfoAsync(queue.Path).Result;
        
                WriteObject(new SbQueue
                {
                    Name = queue.Path,
                    ActiveMessages = queueRuntimeInfo.MessageCountDetails.ActiveMessageCount,
                    DeadLetteredMessages = queueRuntimeInfo.MessageCountDetails.DeadLetterMessageCount
                });
            }
        }
    }
}

