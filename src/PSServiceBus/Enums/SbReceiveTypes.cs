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
        /// Leaves the message in the entity after receiving
        /// </summary>
        ReceiveAndKeep,

        /// <summary>
        /// Just like ReceiveAndKeep, it leaves the message in the entity after receiving
        /// </summary>
        PeekOnly
    }
}
