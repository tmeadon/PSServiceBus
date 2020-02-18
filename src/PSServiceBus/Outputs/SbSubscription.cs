using System;

namespace PSServiceBus.Outputs
{
    /// <summary>
    /// <para type="description">Contains the name of a subscription, the name of the containing topic, and the number of messages in the 'active' and 'dead letter' queues.</para>
    /// </summary>
    public class SbSubscription
    {
        /// <summary>
        /// Name of the subscription
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Name of the topic
        /// </summary>
        public string Topic { get; set; }

        /// <summary>
        /// Number of messages in the active queue
        /// </summary>
        public long ActiveMessages { get; set; }

        /// <summary>
        /// Number of messages in the dead letter queue
        /// </summary>
        public long DeadLetteredMessages { get; set; }

        /// <summary>
        /// Length of the default message time to live for the queue in days
        /// </summary>
        public TimeSpan DefaultMessageTtlInDays { get; set; }

        /// <summary>
        /// A timespan representing the queue's lock duration
        /// </summary>
        public TimeSpan LockDuration { get; set; }

        /// <summary>
        /// The number of times the queue will attempt to deliver a message before it is dead-lettered
        /// </summary>
        public int MaxDeliveryCount { get; set; }

        /// <summary>
        /// A bool that shows if batched operations are enabled or not on the queue
        /// </summary>
        public bool EnableBatchedOperations { get; set; }

        /// <summary>
        /// The status of the queue
        /// </summary>
        public string Status { get; set; }

    }
}
