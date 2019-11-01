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
    }
}
