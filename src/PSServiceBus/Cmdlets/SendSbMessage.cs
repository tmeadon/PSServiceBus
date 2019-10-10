using System.Management.Automation;
using PSServiceBus.Helpers;
using PSServiceBus.Enums;

namespace PSServiceBus.Cmdlets
{
    [Cmdlet(VerbsCommunications.Send, "SbMessage")]
    public class SendSbMessage : PSCmdlet
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
