using System;
using System.Text;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using PSServiceBus.Exceptions;
using PSServiceBus.Enums;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PSServiceBus.Helpers
{
    /// <summary></summary>
    public class SbSender
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

        public void SendMessagesInBatch(string[] Messages)
        {
            IList<Message> payload = null;

            try
            {
                payload = new List<Message>();

                for (int i = 0; i < Messages.Length; i++)
                {
                    byte[] body = Encoding.UTF8.GetBytes(Messages[i]);
                    Message msg = new Message(body);
                    payload.Add(msg);
                }
            }
            catch (Exception E)
            {
                throw new Exception("Something went wrong parsing the messages.", E);
            }

            if (payload != null && payload.Count > 0)
            {
                try
                {
                    var sendTask = messageSender.SendAsync(payload);
                    sendTask.Wait();
                }
                catch (Exception E)
                {
                    throw new Exception("Something while sending the messages in batch to the Service Bus.", E);
                }
            }
            else
            {
                throw new InvalidOperationException("Message collection was empty.");
            }
        }
    }
}
