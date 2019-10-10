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

        public SbReceiver(string NamespaceConnectionString, string EntityPath, SbEntityTypes EntityType, ISbManager sbManager)
        {
            if (sbManager.QueueOrTopicExists(EntityPath, EntityType))
            {
                this.messageReceiver = new MessageReceiver(NamespaceConnectionString, EntityPath);
                this.messageReceiver.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;
            }
            else
            {
                throw new NonExistentEntityException(String.Format("{0} {1} does not exist", EntityType, EntityPath));
            }
        }

        public IList<SbMessage> PeekMessages(int NumberOfMessages)
        {
            IList<SbMessage> result = new List<SbMessage>();
            
            IList<Message> messages = messageReceiver.PeekBySequenceNumberAsync(0, NumberOfMessages).Result;

            foreach (Message message in messages)
            {
                result.Add(new SbMessage
                {
                    MessageId = message.MessageId,
                    MessageBody = ConvertMessageBodyToString(message.Body)
                });
            }

            return result;
        }

        public IList<SbMessage> ReceiveAndDelete(int NumberOfMessages)
        {
            throw new NotImplementedException();
        }

        private string ConvertMessageBodyToString(byte[] bodyBytes)
        {
            string bodyStr = Encoding.UTF8.GetString(bodyBytes);
            return bodyStr;   
        }
    }
}
