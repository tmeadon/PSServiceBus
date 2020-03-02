namespace PSServiceBus.Enums
{
    /// <summary>
    /// Valid Service Bus queue stores
    /// </summary>
    public enum SbQueueStores
    {
        /// <summary>
        /// The 'active' queue store
        /// </summary>
        Active,

        /// <summary>
        /// The 'deadletter' queue store
        /// </summary>
        DeadLetter,

        /// <summary>
        /// The 'scheduled' queue store
        /// </summary>
        Scheduled
    }
}
