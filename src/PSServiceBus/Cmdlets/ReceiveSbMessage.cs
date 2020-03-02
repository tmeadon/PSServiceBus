﻿using System.Collections.Generic;
using System.Management.Automation;
using PSServiceBus.Helpers;
using PSServiceBus.Outputs;
using PSServiceBus.Enums;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Receives a message or messages from an Azure Service Bus queue or subscription.</para>
    /// <para type="description">This cmdlet retrieves a message or messages from an Azure Service Bus queue or subscription. Two receive modes are available:</para>
    /// <para type="description">PeekOnly/ReceiveAndKeep (default) and ReceiveAndDelete which if specified will remove the message from the queue. Multiple messages can be</para>
    /// <para type="description">received using the -ReceiveQty parameter, they will be returned individually to the pipeline. Messages can also be</para>
    /// <para type="description">received from the dead letter queue by adding the -ReceiveFromDeadLetterQueue parameter.</para>
    /// </summary>
    /// <example>
    /// <code>Receive-SbMessage -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue'</code>
    /// <para>Receives a single message from the queue 'example-queue' and leaves it there</para>
    /// <para></para>
    /// </example>
    /// <example>
    /// <code>Receive-SbMessage -NamespaceConnectionString $namespaceConnectionString -TopicName 'example-topic' -SubscriptionName 'example-subscription' -ReceiveQty 5</code>
    /// <para>Receives 5 messages from the subscription called 'example-subscription' in the topic 'example-topic' and leaves them there</para>
    /// <para></para>
    /// </example>
    /// <example>
    /// <code>Receive-SbMessage -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue' -ReceiveType ReceiveAndDelete</code>
    /// <para>Receives a single message from the queue 'example-queue' and removes it from the queue</para>
    /// <para></para>
    /// </example>
    /// <example>
    /// <code>Receive-SbMessage -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue' -ReceiveFromDeadLetterQueue</code>
    /// <para>Receives a single message from the dead letter queue for queue 'example-queue' and leaves it there</para>
    /// <para></para>
    /// </example>
    [Cmdlet(VerbsCommunications.Receive, "SbMessage")]
    [OutputType(typeof(SbMessage))]
    public class ReceiveSbMessage : PSCmdlet
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
        [Alias("NumberOfMessagesToRetrieve")]
        public int ReceiveQty { get; set; } = 1;

        /// <summary>
        /// <para type="description">Specifies the receive behaviour - defaults to PeekOnly.</para>
        /// </summary>
        [Parameter]
        public SbReceiveTypes ReceiveType { get; set; } = SbReceiveTypes.PeekOnly;

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

            if (this.ReceiveType == SbReceiveTypes.ReceiveAndKeep)
            {
                WriteWarning("The option ReceiveAndKeep will be deprecated in future versions. Please use 'PeekOnly' instead.");
            }

            if (this.ParameterSetName == "ReceiveFromQueue")
            {
                sbReceiver = new SbReceiver(NamespaceConnectionString, QueueName, ReceiveFromDeadLetterQueue, sbManager);
            }
            else
            {
                sbReceiver = new SbReceiver(NamespaceConnectionString, TopicName, SubscriptionName, ReceiveFromDeadLetterQueue, sbManager);
            }

            IList<SbMessage> sbMessages = sbReceiver.ReceiveMessages(ReceiveQty, ReceiveType);

            foreach (SbMessage sbMessage in sbMessages)
            {
                WriteObject(sbMessage);
            }
        }
    }
}
