namespace PSServiceBus.Enums
{
    /// <summary>
    /// <para type="description">Valid ways to receive a message from a Service Bus entity</para>
    /// </summary>
    public enum SbReceiveTypes
    {
        /// <summary>
        /// Removes the message from the entity after receiving
        /// </summary>
        ReceiveAndDelete,

        /// <summary>
        /// Just like PeekOnly, it leaves the message in the entity after receiving
        /// </summary>
        ReceiveAndKeep,

        /// <summary>
        /// Uses the Peek feature and leaves the message in the entity after receiving
        /// </summary>
        PeekOnly
    }
}
