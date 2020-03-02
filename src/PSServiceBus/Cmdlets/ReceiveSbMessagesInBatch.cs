using System.Collections.Generic;
using System.Management.Automation;
using PSServiceBus.Helpers;
using PSServiceBus.Outputs;
using PSServiceBus.Enums;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Receives messages in batch from an Azure Service Bus queue or subscription.</para>
    /// <para type="description">This cmdlet retrieves messages in batch from an Azure Service Bus queue or subscription. Two receive modes are available:</para>
    /// <para type="description">ReceiveAndKeep (default) and ReceiveAndDelete which if specified will remove the message from the queue.  Multiple messages can be</para>
    /// <para type="description">received using the -ReceiveQty parameter, they will be returned individually to the pipeline. Messages can also be</para>
    /// <para type="description">received from the dead letter queue by adding the -ReceiveFromDeadLetterQueue parameter.</para>
    /// </summary>
    /// <example>
    /// <code>Receive-SbMessagesInBatch -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue'</code>
    /// <para>Receives a single message in batch from the queue 'example-queue' and leaves it there</para>
    /// <para></para>
    /// </example>
    /// <example>
    /// <code>Receive-SbMessagesInBatch -NamespaceConnectionString $namespaceConnectionString -TopicName 'example-topic' -SubscriptionName 'example-subscription' -ReceiveQty 5</code>
    /// <para>Receives 5 messages in batch from the subscription called 'example-subscription' in the topic 'example-topic' and leaves them there</para>
    /// <para></para>
    /// </example>
    /// <example>
    /// <code>Receive-SbMessagesInBatch -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue' -ReceiveType ReceiveAndDelete</code>
    /// <para>Receives a single message in batch from the queue 'example-queue' and removes it from the queue</para>
    /// <para></para>
    /// </example>
    /// <example>
    /// <code>Receive-SbMessagesInBatch -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue' -ReceiveFromDeadLetterQueue</code>
    /// <para>Receives a single message in batch from the dead letter queue for queue 'example-queue' and leaves it there</para>
    /// <para></para>
    /// </example>
    [Cmdlet(VerbsCommunications.Receive, "SbMessagesInBatch")]
    [OutputType(typeof(SbMessage))]
    public class ReceiveSbMessagesInBatch : PSCmdlet
    {
        /// <summary>
        /// <para type="description">A connection string with 'Manage' rights for the Azure Service Bus Namespace.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        /// <summary>
        /// <para type="description">The name of the queue to retrieve messages from.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "ReceiveFromQueue"
        )]
        public string QueueName { get; set; }

        /// <summary>
        /// <para type="description">The name of the topic containing the subscription to retrieve messages from.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "ReceiveFromSubscription"
        )]
        public string TopicName { get; set; }

        /// <summary>
        /// <para type="description">The name of the subscription to retrieve messages from.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "ReceiveFromSubscription"
        )]
        public string SubscriptionName { get; set; }

        /// <summary>
        /// <para type="description">The number of messages to retrieve - defaults to 1.</para>
        /// </summary>
        [Parameter]
        public int ReceiveQty { get; set; } = 1;

        /// <summary>
        /// <para type="description">Specifies the receive behaviour - defaults to ReceiveAndKeep.</para>
        /// </summary>
        [Parameter]
        public SbReceiveTypes ReceiveType { get; set; } = SbReceiveTypes.ReceiveAndKeep;

        /// <summary>
        /// <para type="description">Retrieves messages from the entity's dead letter queue.</para>
        /// </summary>
        [Parameter]
        public SwitchParameter ReceiveFromDeadLetterQueue { get; set; }

        /// <summary>
        /// Main cmdlet method.
        /// </summary>
        protected override void ProcessRecord()
        {
            SbReceiver sbReceiver;
            SbManager sbManager = new SbManager(NamespaceConnectionString);

            SbQueueStores receiveFromStore = SbQueueStores.Active;

            if (ReceiveFromDeadLetterQueue)
            {
                receiveFromStore = SbQueueStores.DeadLetter;
            }

            if (this.ParameterSetName == "ReceiveFromQueue")
            {
                sbReceiver = new SbReceiver(NamespaceConnectionString, QueueName, receiveFromStore, sbManager);
            }
            else
            {
                sbReceiver = new SbReceiver(NamespaceConnectionString, TopicName, SubscriptionName, receiveFromStore, sbManager);
            }

            IList<SbMessage> sbMessages = sbReceiver.ReceiveMessagesInBatch(ReceiveQty, ReceiveType);

            foreach (SbMessage sbMessage in sbMessages)
            {
                WriteObject(sbMessage);
            }
        }
    }
}
