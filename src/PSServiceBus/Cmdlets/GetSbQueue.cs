using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;

namespace PSServiceBus.Cmdlets
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

            var output = BuildQueueList(sbManager, QueueName);

            foreach (var item in output)
            {
                WriteObject(item);
            }
        }

        private IList<SbQueue> BuildQueueList(ISbManager SbManager, string QueueName)
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

