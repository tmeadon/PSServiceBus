using System.Collections.Generic;
using System.Management.Automation;
using PSServiceBus.Helpers;
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

            IList<SbMessage> messages = sbReceiver.PeekMessages(NumberOfMessagesToRetrieve);

            foreach (SbMessage message in messages)
            {
                WriteObject(message);
            }
        }
    }
}
