namespace PSServiceBus.Outputs
{
    /// <summary>
    /// <para type="description">Contains the name of a queue and the number of messages in the 'active' and 'dead letter' queues.</para>
    /// </summary>
    public class SbQueue
    {
        /// <summary>
        /// Name of the queue
        /// </summary>
        public string Name { get; set; }

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
