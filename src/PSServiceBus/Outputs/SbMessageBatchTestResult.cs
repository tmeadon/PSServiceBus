using System;
using System.Collections.Generic;
using Microsoft.Azure.ServiceBus.Management;

namespace PSServiceBus.Outputs
{
    /// <summary>
    /// Contains the id and the body for a service bus message
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
        public bool ValidForBasicSku;

        /// <summary>
        /// Whether or not the batch is within the constraints of the 'basic' Service Bus Namespace sku
        /// </summary>
        public bool ValidForStandardSku;

        /// <summary>
        /// Whether or not the batch is within the constraints of the 'premium' Service Bus Namespace sku
        /// </summary>
        public bool ValidForPremiumSku;

        /// <summary>
        /// Sku of the in-scope namespace
        /// </summary>
        public MessagingSku CurrentNamespaceSku;

        /// <summary>
        /// Whether or not the batch is within the contstraints of the in-scope namespace
        /// </summary>
        public bool ValidForCurrentNamespace;
    }
}
