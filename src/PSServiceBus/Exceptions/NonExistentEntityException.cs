using System;

namespace PSServiceBus.Exceptions
{
    /// <summary>
    /// Tells the user that the Service Bus entity doesn't exist
    /// </summary>
    public class NonExistentEntityException : Exception
    {
        /// <summary>
        /// Basic constructor
        /// </summary>
        public NonExistentEntityException() : base() { }

        /// <summary>
        /// This constructor allows control of the exception message
        /// </summary>
        /// <param name="message">Message to insert into the exception</param>
        public NonExistentEntityException(string message) : base(message) { }
    }
}
