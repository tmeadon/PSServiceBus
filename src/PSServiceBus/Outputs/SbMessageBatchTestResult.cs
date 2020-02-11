using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Enums;

namespace PSServiceBus.Outputs
{
    /// <summary>
    /// Contains the result of a message batch test
    /// </summary>
    public class SbMessageBatchTestResult
    {
        /// <summary>
        /// Size of the batch
        /// </summary>
        public string BatchSize;

        /// <summary>
        /// Number of messages in the batch
        /// </summary>
        public int NumberOfMessages;

        /// <summary>
        /// Whether or not the batch is within the constraints of the 'basic' Service Bus Namespace sku
        /// </summary>
        public SkuValidityOutput ValidForBasicSku;

        /// <summary>
        /// Whether or not the batch is within the constraints of the 'basic' Service Bus Namespace sku
        /// </summary>
        public SkuValidityOutput ValidForStandardSku;

        /// <summary>
        /// Whether or not the batch is within the constraints of the 'premium' Service Bus Namespace sku
        /// </summary>
        public SkuValidityOutput ValidForPremiumSku;

        /// <summary>
        /// Sku of the in-scope namespace
        /// </summary>
        public MessagingSku? CurrentNamespaceSku;

        /// <summary>
        /// Whether or not the batch is within the contstraints of the in-scope namespace
        /// </summary>
        public SkuValidityOutput? ValidForCurrentNamespace;

        /// <summary>
        /// Sub-object for the sku validity members
        /// </summary>
        public struct SkuValidityOutput
        {
            public bool Result;

            public SbBatchTestResults? Reason;
        }
    }
}
