using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management;
using System.Management.Automation;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;
using PSServiceBus.Outputs;

namespace PSServiceBus
{
    [Cmdlet(VerbsCommon.Get, "SbQueue")]
    [OutputType(typeof(SbQueue))]
    public class GetSbQueue: Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = false)]
        public string QueueNameStartsWith { get; set; }
        
        protected override void ProcessRecord()
        {
            IEnumerable<QueueDescription> queues;
            NamespaceManager namespaceManager = NamespaceManager.CreateFromConnectionString(NamespaceConnectionString);
            
            if (QueueNameStartsWith != null)
            {
                queues = namespaceManager.GetQueues(String.Format($"startswith(path, '" + QueueNameStartsWith + "') eq true"));
            }
            else
            {
                queues = namespaceManager.GetQueues();
            }
            
            foreach (var queue in queues)
            {
                MessageCountDetails messageCountDetails = queue.MessageCountDetails;
        
                WriteObject(new SbQueue
                {
                    Name = queue.Path,
                    ActiveMessages = messageCountDetails.ActiveMessageCount,
                    DeadLetteredMessages = messageCountDetails.DeadLetterMessageCount
                });
            }
        }
    }
}

