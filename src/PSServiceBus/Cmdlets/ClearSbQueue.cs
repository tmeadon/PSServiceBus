using System.Collections.Generic;
using System.Management.Automation;
using PSServiceBus.Helpers;
using PSServiceBus.Outputs;
using PSServiceBus.Enums;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Clears all messages from an Azure Service Bus queue or subscription.</para>
    /// <para type="description">This cmdlet clears all messages from an Azure Service Bus queue or subscription.</para>
    /// <para type="description">The messages will be destroyed and not outputted to the console.</para>
    /// </summary>
    /// <example>
    /// <code>Clear-SbQueue -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue'</code>
    /// <para>Clears all messages from the queue 'example-queue'</para>
    /// <para></para>
    /// </example>
    /// <example>
    /// <code>Clear-SbQueue -NamespaceConnectionString $namespaceConnectionString -TopicName 'example-topic' -SubscriptionName 'example-subscription'</code>
    /// <para>Clears all messages from the subscription called 'example-subscription' in the topic 'example-topic'</para>
    /// <para></para>
    /// </example>
    [Cmdlet(VerbsCommon.Clear, "SbQueue")]
    public class ClearSbQueue : PSCmdlet
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
            ParameterSetName = "ClearQueue"
        )]
        public string QueueName { get; set; }

        /// <summary>
        /// <para type="description">The name of the topic containing the subscription to retrieve messages from.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "ClearSubscription"
        )]
        public string TopicName { get; set; }

        /// <summary>
        /// <para type="description">The name of the subscription to retrieve messages from.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "ClearSubscription"
        )]
        public string SubscriptionName { get; set; }

        /// <summary>
        /// <para type="description">Retrieves messages from the entity's dead letter queue.</para>
        /// </summary>
        [Parameter]
        public SwitchParameter DeadLetterQueue { get; set; }

        /// <summary>
        /// <para type="description">Prevents the cmdlet from outputting the queue/subscription after purge is complete</para>
        /// </summary>
        [Parameter]
        public SwitchParameter NoOutput { get; set; }

        /// <summary>
        /// Main cmdlet method.
        /// </summary>
        protected override void ProcessRecord()
        {
            SbReceiver sbReceiver;
            SbManager sbManager = new SbManager(NamespaceConnectionString);

            if (this.ParameterSetName == "ClearQueue")
            {
                sbReceiver = new SbReceiver(NamespaceConnectionString, QueueName, DeadLetterQueue, sbManager, true);
            }
            else
            {
                sbReceiver = new SbReceiver(NamespaceConnectionString, TopicName, SubscriptionName, DeadLetterQueue, sbManager, true);
            }

            sbReceiver.PurgeMessages();
            sbReceiver.Dispose();

            // use existing PSServiceBus cmdlets to retrieve the queue/subscription to show user the result of the purge
            if (!this.NoOutput)
            {
                if (this.ParameterSetName == "ClearQueue")
                {
                    GetSbQueue getSbQueue = new GetSbQueue();
                    getSbQueue.NamespaceConnectionString = NamespaceConnectionString;
                    getSbQueue.QueueName = QueueName;
                    WriteObject(getSbQueue.Invoke());
                }
                else
                {
                    GetSbSubscription getSbSubscription = new GetSbSubscription();
                    getSbSubscription.NamespaceConnectionString = NamespaceConnectionString;
                    getSbSubscription.TopicName = TopicName;
                    getSbSubscription.SubscriptionName = SubscriptionName;
                    WriteObject(getSbSubscription.Invoke());
                }
            }
        }
    }
}
