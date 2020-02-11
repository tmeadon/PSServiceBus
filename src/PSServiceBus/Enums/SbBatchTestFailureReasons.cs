namespace PSServiceBus.Enums
{
    /// <summary>
    /// Valid reasons for the message batch test to fail
    /// </summary>
    public enum SbBatchTestResults
    {
        /// <summary>
        /// No failure
        /// </summary>
        BatchWithinLimits,
        
        /// <summary>
        /// Batch is over the size limit
        /// </summary>
        BatchTooLarge,

        /// <summary>
        /// Batch contains more than the allowed number of messages
        /// </summary>
        TooManyItems
    }
}
