using System.Collections.Generic;
using System.Management.Automation;
using PSServiceBus.Helpers;
using PSServiceBus.Outputs;
using PSServiceBus.Enums;

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

        [Parameter]
        public SbReceiveTypes ReceiveType { get; set; } = SbReceiveTypes.ReceiveAndKeep;

        protected override void ProcessRecord()
        {
            SbReceiver sbReceiver;
            SbManager sbManager = new SbManager(NamespaceConnectionString);

            if (this.ParameterSetName == "ReceiveFromQueue")
            {
                sbReceiver = new SbReceiver(NamespaceConnectionString, QueueName, sbManager);
            }
            else
            {
                sbReceiver = new SbReceiver(NamespaceConnectionString, TopicName, SubscriptionName, sbManager);
            }

            IList<SbMessage> sbMessages = sbReceiver.ReceiveMessages(NumberOfMessagesToRetrieve, ReceiveType);

            foreach (SbMessage sbMessage in sbMessages)
            {
                WriteObject(sbMessage);
            }
        }
    }
}
