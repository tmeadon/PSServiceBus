using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Gets a queue by name or a list of all queues from an Azure Service Bus Namespace.  Returns the number of messages in the active and dead letter queues.</para>
    /// <para type="description">Gets a queue by name or a list of all queues from an Azure Service Bus Namespace.  Returns the number of messages in the active and dead letter queues.</para>
    /// </summary>
    /// <example>
    /// <code>Get-SbQueue -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue'</code>
    /// <para>This gets information about a single queue called 'example-queue'.</para>
    /// </example>
    /// <example>
    /// <code>Get-SbQueue -NamespaceConnectionString $namespaceConnectionString</code>
    /// <para>This gets information about all queues.</para>
    /// </example>
    [Cmdlet(VerbsCommon.Get, "SbQueue")]
    [OutputType(typeof(SbQueue))]
    public class GetSbQueue : Cmdlet
    {
        /// <summary>
        /// <para type="description">A connection string with 'Manage' rights for the Azure Service Bus Namespace.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        /// <summary>
        /// <para type="description">The name of the queue to retrieve.  All queues are returned if not specified.</para>
        /// </summary>
        [Parameter(Mandatory = false)]
        public string QueueName { get; set; } = null;

        /// <summary>
        /// Main cmdlet method.
        /// </summary>
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

                SbQueue sbQueue = new SbQueue {
                    Name = queue.Path,
                    ActiveMessages = queueRuntimeInfo.MessageCountDetails.ActiveMessageCount,
                    DeadLetteredMessages = queueRuntimeInfo.MessageCountDetails.DeadLetterMessageCount,
                    ScheduledMessageCount = queueRuntimeInfo.MessageCountDetails.ScheduledMessageCount,
                    DefaultMessageTtlInDays = queue.DefaultMessageTimeToLive,
                    LockDuration = queue.LockDuration,
                    DuplicateDetectionHistoryTimeWindow = queue.DuplicateDetectionHistoryTimeWindow,
                    MaxDeliveryCount = queue.MaxDeliveryCount,
                    EnableBatchedOperations = queue.EnableBatchedOperations,
                    MaxSizeInMB = queue.MaxSizeInMB,
                    CurrentSizeInMB = (queueRuntimeInfo.SizeInBytes / 1000000),
                    Status = queue.Status.ToString()
                };

                sbQueue.PercentageCapacityFree = (int)(((float)(sbQueue.MaxSizeInMB - sbQueue.CurrentSizeInMB) / sbQueue.MaxSizeInMB) * 100);

                result.Add(sbQueue);
            }

            return result;
        }
    }
}

