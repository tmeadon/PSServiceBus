using System.Collections.Generic;
using System.Management.Automation;
using PSServiceBus.Helpers;
using PSServiceBus.Enums;
using PSServiceBus.Outputs;

namespace PSServiceBus.Cmdlets
{
    [Cmdlet(VerbsCommunications.Receive, "SbMessage")]
    public class ReceiveSbMessage : PSCmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(
            Mandatory = true,
            ParameterSetName = "ReceiveFromQueue"
        )]
        public string QueueName { get; set; }

        [Parameter(
            Mandatory = true,
            ParameterSetName = "ReceiveFromSubscription"
        )]
        public string TopicName { get; set; }

        [Parameter(
            Mandatory = true,
            ParameterSetName = "ReceiveFromSubscription"
        )]
        public string SubscriptionName { get; set; }

        [Parameter]
        public int NumberOfMessagesToRetrieve { get; set; } = 1;

        private SbEntityTypes entityType;

        private string entityPath;

        protected override void ProcessRecord()
        {
            // TODO HANDLE SUBSCRIPTIONS
        


            SbManager sbManager = new SbManager(NamespaceConnectionString);

            switch (this.ParameterSetName)
            {
                case "ReceiveFromQueue":
                    entityPath = QueueName;
                    entityType = SbEntityTypes.Queue;
                    break;
                case "ReceiveFromSubscription":
                    entityPath = sbManager.BuildSubscriptionPath(TopicName, SubscriptionName);
                    entityType = SbEntityTypes.Subscription;
                    break;
            }

            SbReceiver sbReceiver = new SbReceiver(NamespaceConnectionString, entityPath, entityType, sbManager);

            IList<SbMessage> messages = sbReceiver.PeekMessages(NumberOfMessagesToRetrieve);

            foreach (SbMessage message in messages)
            {
                WriteObject(message);
            }
        }
    }
}
