using System.Management.Automation;
using PSServiceBus.Helpers;
using PSServiceBus.Enums;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Sends a message to an Azure Service Bus queue or topic.</para>
    /// <para type="description">Sends a message to an Azure Service Bus queue or topic.</para>
    /// </summary>
    /// <example>
    /// <code>Send-SbMessage -NamespaceConnectionString $namespaceConnectionString -QueueName 'example-queue'  -Message '{ "example": "message" }'</code>
    /// <para>This sends a message to the queue 'example-queue' with body '{ "example": "message" }'.</para>
    /// </example>
    /// <example>
    /// <code>Send-SbMessage -NamespaceConnectionString $namespaceConnectionString -TopicName 'example-topic'  -Message '{ "example": "message" }'</code>
    /// <para>This sends a message to the topic 'example-topic' with body '{ "example": "message" }'.</para>
    /// </example>
    [Cmdlet(VerbsCommunications.Send, "SbMessage")]
    public class SendSbMessage : PSCmdlet
    {
        /// <summary>
        /// <para type="description">A connection string with 'Manage' rights for the Azure Service Bus Namespace.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        /// <summary>
        /// <para type="description">Name of the queue to send a message to.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "SendToQueue"
        )]
        public string QueueName { get; set; }

        /// <summary>
        /// <para type="description">Name of the topic to send a message to.</para>
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "SendToTopic"
        )]
        public string TopicName { get; set; }

        /// <summary>
        /// <para type="description">Body of the message to send.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string Message { get; set; }

        private string entityPath;

        private SbEntityTypes entityType;

        /// <summary>
        /// Main cmdlet method.
        /// </summary>
        protected override void ProcessRecord()
        {
            switch (this.ParameterSetName)
            {
                case "SendToQueue":
                    entityPath = QueueName;
                    entityType = SbEntityTypes.Queue;
                    break;
                case "SendToTopic":
                    entityPath = TopicName;
                    entityType = SbEntityTypes.Topic;
                    break;
            }

            SbManager sbManager = new SbManager(NamespaceConnectionString);

            SbSender sbSender = new SbSender(NamespaceConnectionString, entityPath, entityType, sbManager);

            sbSender.SendMessage(Message);
        }
    }
}
