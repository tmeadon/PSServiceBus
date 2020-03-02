using System;
using System.Collections.Generic;

namespace PSServiceBus.Outputs
{
    /// <summary>
    /// Contains the id and the body for a service bus message
    /// </summary>
    public class SbMessage
    {
        /// <summary>
        /// Message ID
        /// </summary>
        public string MessageId;

        /// <summary>
        /// Message body
        /// </summary>
        public string MessageBody;

        /// <summary>
        /// System Properties
        /// </summary>
        public IDictionary<string, Object> SystemProperties;

        /// <summary>
        /// User Properties
        /// </summary>
        public IDictionary<string,Object> UserProperties;

        /// <summary>
        /// Datetime the messaged is scheduled to be enqueued
        /// </summary>
        public DateTime ScheduledEnqueuedTimeUtc;
    }
}
