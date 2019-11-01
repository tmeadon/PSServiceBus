using System;
using System.Collections.Generic;
using System.Text;

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
    }
}
