using System.Collections.Generic;

namespace PSServiceBus.Outputs
{
    /// <summary>
    /// <para type="description">Contains the name of a topic and a list of its subscriptions.</para>
    /// </summary>
    class SbTopic
    {
        /// <summary>
        /// Name of the topic
        /// </summary>
        public string TopicName { get; set; }

        /// <summary>
        /// List of subscriptions in the topic
        /// </summary>
        public List<string> Subscriptions { get; set; }
    }
}
