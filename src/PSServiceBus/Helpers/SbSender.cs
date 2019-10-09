using System;
using System.Text;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using PSServiceBus.Exceptions;
using PSServiceBus.Enums;

namespace PSServiceBus.Helpers
{
    public class SbSender
    {
        private readonly MessageSender messageSender;
        public TransportType TransportType;

        public SbSender(string NamespaceConnectionString, string EntityPath, SbEntityTypes EntityType, ISbManager sbManager)
        {
            if (sbManager.QueueOrTopicExists(sbManager, EntityPath, EntityType))
            {
                string webSocketsConnectionString = SetMessageTransportToWebSockets(NamespaceConnectionString);
                this.messageSender = new MessageSender(webSocketsConnectionString, EntityPath, null);
                this.TransportType = messageSender.ServiceBusConnection.TransportType;
            }
            else
            {
                throw new NonExistentEntityException(String.Format("{0} {1} does not exist", EntityType, EntityPath));
            }           
        }

        private string SetMessageTransportToWebSockets(string connectionString)
        {
            if (!connectionString.Contains("TransportType=AmqpWebSockets"))
            {
                return connectionString + ";TransportType=AmqpWebSockets";
            }
            else
            {
                return connectionString;
            }
        }

        public void SendMessage(string MessageBody)
        {
            byte[] body = Encoding.UTF8.GetBytes(MessageBody);
            Message message = new Message(body);
            messageSender.SendAsync(message);
        }
    }
}
