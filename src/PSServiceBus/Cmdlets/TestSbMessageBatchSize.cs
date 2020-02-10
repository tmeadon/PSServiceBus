using System;
using System.Text;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;
using Microsoft.Azure.ServiceBus;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Tests whether a connection string is valid or not.</para>
    /// <para type="description">Tests whether a connection string is valid or not.</para>
    /// </summary>
    /// <example>
    /// <code>Test-SbConnectionString -NamespaceConnectionString $namespaceConnectionString</code>
    /// <para>This tests whether $namespaceConnectionString is valid or not.</para>
    /// </example>
    [Cmdlet(VerbsDiagnostic.Test, "SbMessageBatchSize")]
    [OutputType(typeof(SbMessageBatchTestResult))]
    public class TestSbMessageBatchSize : Cmdlet
    {

        /// <summary>
        /// <para type="description">A connection string with 'Manage' rights for the Azure Service Bus Namespace.</para>
        /// </summary>
        [Parameter()]
        public string NamespaceConnectionString { get; set; }

        /// <summary>
        /// <para type="description">Batch of messages to be tested</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string[] Messages { get; set; }

        /// <summary>
        /// Main cmdlet method.
        /// </summary>
        protected override void ProcessRecord()
        {
            SbMessageBatchTestResult result = new SbMessageBatchTestResult{
                BatchSize = string.Format("{0}B", GetMessageBatchSize(Messages).ToString()),
                NumberOfMessages = Messages.Length,
                ValidForBasicSku = TestMessageBatch(Messages, MessagingSku.Basic),
                ValidForStandardSku = TestMessageBatch(Messages, MessagingSku.Standard),
                ValidForPremiumSku = TestMessageBatch(Messages, MessagingSku.Premium),
                CurrentNamespaceSku = null,
                ValidForCurrentNamespace = null
            };

            if (NamespaceConnectionString != null)
            {
                SbManager sbManager = new SbManager(NamespaceConnectionString);
                MessagingSku currentSku = sbManager.GetNamespaceSku();

                result.CurrentNamespaceSku = currentSku;
                result.ValidForCurrentNamespace = TestMessageBatch(Messages, currentSku);
            }

            WriteObject(result);

        }

        public int GetMessageMaxSizeInBytes(MessagingSku sku)
        {
            switch (sku)
            {
                case MessagingSku.Basic:
                case MessagingSku.Standard:
                    return 256000;
                
                case MessagingSku.Premium:
                    return 1000000;

                default:
                    throw new NotImplementedException(string.Format("Maximum message size for sku '{0}' is unknown", sku.ToString()));
            }
        }

        public long GetMessageBatchSize(string[] Messages)
        {
            long batchSize = 0;

            for (int i = 0; i < Messages.Length; i++)
            {
                byte[] body = Encoding.UTF8.GetBytes(Messages[i]);
                Message message = new Message(body);
                batchSize += message.Size;
            }
            
            return batchSize;
        }

        public bool TestMessageBatch(string[] Messages, MessagingSku NamespaceSku)
        {
            return this.GetMessageBatchSize(Messages) < this.GetMessageMaxSizeInBytes(NamespaceSku) &&
                Messages.Length < 100 ? true : false;
        }
    }
}