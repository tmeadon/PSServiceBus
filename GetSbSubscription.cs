using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management.Automation;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;
using PSServiceBus.Outputs;

namespace PSServiceBus
{
    [Cmdlet(VerbsCommon.Get, "SbSubscription")]
    [OutputType(typeof(SbSubscription))]
    public class GetSbSubscription: Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true)]
        public string TopicName { get; set; }

        private NamespaceManager namespaceManager;

        protected override void BeginProcessing()
        {
            this.namespaceManager = NamespaceManager.CreateFromConnectionString(NamespaceConnectionString);
        }

        protected override void ProcessRecord()
        {
            IEnumerable<SubscriptionDescription> subscriptions;

            subscriptions = namespaceManager.GetSubscriptions(TopicName);

            foreach (var sub in subscriptions)
            {
                MessageCountDetails messageCountDetails = sub.MessageCountDetails;

                WriteObject(new SbSubscription
                {
                    Name = sub.Name,
                    Topic = sub.TopicPath,
                    ActiveMessages = messageCountDetails.ActiveMessageCount,
                    DeadLetteredMessages = messageCountDetails.DeadLetterMessageCount
                });
            }
        }
    }
}
