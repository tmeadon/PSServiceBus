using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using PSServiceBus.Outputs;
using PSServiceBus.Enums;
using PSServiceBus.Exceptions;

namespace PSServiceBus.Helpers
{
    public class SbReceiver : ISbReceiver
    {
        private readonly MessageReceiver messageReceiver;

        public SbReceiver(string NamespaceConnectionString, string QueueName, ISbManager sbManager)
        {
            if (sbManager.QueueOrTopicExists(QueueName, SbEntityTypes.Queue))
            {
                this.messageReceiver = CreateMessageReceiver(NamespaceConnectionString, QueueName);
            }
            else
            {
                throw new NonExistentEntityException(String.Format("{0} {1} does not exist", SbEntityTypes.Queue, QueueName));
            }
        }

        public SbReceiver(string NamespaceConnectionString, string TopicName, string SubscriptionName, ISbManager sbManager)
        {
            if (sbManager.SubscriptionExists(TopicName, SubscriptionName))
            {
                string subscriptionPath = sbManager.BuildSubscriptionPath(TopicName, SubscriptionName);
                this.messageReceiver = CreateMessageReceiver(NamespaceConnectionString, subscriptionPath);
            }
            else
            {
                throw new NonExistentEntityException(String.Format("Subscription {0} does not exist in Topic {1}", SubscriptionName, TopicName));
            }
        }

        public IList<SbMessage> PeekMessages(int NumberOfMessages)
        {            
            IList<Message> messages = messageReceiver.PeekBySequenceNumberAsync(0, NumberOfMessages).Result;

            return BuildMessageList(messages);
        }

        public IList<SbMessage> ReceiveAndDelete(int NumberOfMessages)
        { 
            IList<Message> messages = messageReceiver.ReceiveAsync(NumberOfMessages).Result;

            return BuildMessageList(messages);
        }

        private MessageReceiver CreateMessageReceiver(string NamespaceConnectionString, string EntityPath)
        {
            MessageReceiver messageReceiver = new MessageReceiver(NamespaceConnectionString, EntityPath, ReceiveMode.ReceiveAndDelete);
            messageReceiver.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;
            return messageReceiver;
        }

        private string ConvertMessageBodyToString(byte[] bodyBytes)
        {
            string bodyStr = Encoding.UTF8.GetString(bodyBytes);
            return bodyStr;   
        }

        private IList<SbMessage> BuildMessageList(IList<Message> Messages)
        {
            IList<SbMessage> result = new List<SbMessage>();

            foreach (Message message in Messages)
            {
                result.Add(new SbMessage
                {
                    MessageId = message.MessageId,
                    MessageBody = ConvertMessageBodyToString(message.Body)
                });
            }

            return result;
        }
    }
}
