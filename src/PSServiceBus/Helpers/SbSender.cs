using System;
using System.Text;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using PSServiceBus.Exceptions;
using PSServiceBus.Enums;

namespace PSServiceBus.Helpers
{
    public class SbSender : ISbSender
    {
        private readonly MessageSender messageSender;

        public SbSender(string NamespaceConnectionString, string EntityPath, SbEntityTypes EntityType, ISbManager sbManager)
        {
            if (sbManager.QueueOrTopicExists(EntityPath, EntityType))
            {
                this.messageSender = new MessageSender(NamespaceConnectionString, EntityPath, null);
                this.messageSender.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;
            }
            else
            {
                throw new NonExistentEntityException(String.Format("{0} {1} does not exist", EntityType, EntityPath));
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
