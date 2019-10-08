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
using PSServiceBus.Helpers;

namespace PSServiceBus
{
    [Cmdlet(VerbsCommon.Get, "SbQueue")]
    [OutputType(typeof(SbQueue))]
    public class GetSbQueue : Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = false)]
        public string QueueName { get; set; } = null;


        protected override void ProcessRecord()
        {
            SbManager sbManager = new SbManager(NamespaceConnectionString);

            var output = ProduceOutput(sbManager, QueueName);

            foreach (var item in output)
            {
                WriteObject(item);
            }
        }

        private IList<SbQueue> ProduceOutput(ISbManager SbManager, string QueueName)
        {
            IList<SbQueue> result = new List<SbQueue>();
            IList<QueueDescription> queues = new List<QueueDescription>();

            if (QueueName != null)
            {
                queues.Add(SbManager.GetQueueByName(QueueName));
            }
            else
            {
                queues = SbManager.GetAllQueues();
            }

            foreach (var queue in queues)
            {
                QueueRuntimeInfo queueRuntimeInfo = SbManager.GetQueueRuntimeInfo(queue.Path);

                result.Add(new SbQueue
                {
                    Name = queue.Path,
                    ActiveMessages = queueRuntimeInfo.MessageCountDetails.ActiveMessageCount,
                    DeadLetteredMessages = queueRuntimeInfo.MessageCountDetails.DeadLetterMessageCount
                });
            }

            return result;
        }
    }
}

