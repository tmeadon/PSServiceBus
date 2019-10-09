using System.Management.Automation;
using PSServiceBus.Helpers;
using PSServiceBus.Enums;

namespace PSServiceBus
{
    [Cmdlet(VerbsCommunications.Send, "SbMessage")]
    public class SendSbMessage : Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(
            Mandatory = true,
            ParameterSetName = "SendToQueue"
        )]
        public string QueueName { get; set; }

        [Parameter(
            Mandatory = true,
            ParameterSetName = "SendToTopic"
        )]
        public string TopicName { get; set; }

        [Parameter(Mandatory = true)]
        public string Message { get; set; }

        private string entityPath;

        private SbEntityTypes entityType;

        protected override void ProcessRecord()
        {
            if (QueueName != null)
            {
                entityPath = QueueName;
                entityType = SbEntityTypes.Queue;
            }
            else
            {
                entityPath = TopicName;
                entityType = SbEntityTypes.Topic;
            }

            SbManager sbManager = new SbManager(NamespaceConnectionString);

            SbSender sbSender = new SbSender(NamespaceConnectionString, entityPath, entityType, sbManager);

            sbSender.SendMessage(Message);
        }
    }
}
