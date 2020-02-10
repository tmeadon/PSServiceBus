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
    /// <summary></summary>
    public class SbReceiver
    {
        private readonly MessageReceiver messageReceiver;

        public SbReceiver(string NamespaceConnectionString, string QueueName, bool ReceiveFromDeadLetter, ISbManager sbManager, bool PurgeMode = false)
        {
            ReceiveMode receiveMode = ReceiveMode.PeekLock;

            if(PurgeMode)
            {
                receiveMode = ReceiveMode.ReceiveAndDelete;
            }

            if (sbManager.QueueOrTopicExists(QueueName, SbEntityTypes.Queue))
            {
                string entityPath = QueueName;

                if (ReceiveFromDeadLetter)
                {
                    entityPath = sbManager.BuildDeadLetterPath(QueueName);
                }

                this.messageReceiver = CreateMessageReceiver(NamespaceConnectionString, entityPath, receiveMode);
            }
            else
            {
                throw new NonExistentEntityException(String.Format("{0} {1} does not exist", SbEntityTypes.Queue, QueueName));
            }
        }

        public SbReceiver(string NamespaceConnectionString, string TopicName, string SubscriptionName, bool ReceiveFromDeadLetter, ISbManager sbManager, bool PurgeMode = false)
        {
            ReceiveMode receiveMode = ReceiveMode.PeekLock;

            if (PurgeMode)
            {
                receiveMode = ReceiveMode.ReceiveAndDelete;
            }

            if (sbManager.SubscriptionExists(TopicName, SubscriptionName))
            {
                string subscriptionPath = sbManager.BuildSubscriptionPath(TopicName, SubscriptionName);
                string entityPath = subscriptionPath;

                if (ReceiveFromDeadLetter)
                {
                    entityPath = sbManager.BuildDeadLetterPath(subscriptionPath);
                }

                this.messageReceiver = CreateMessageReceiver(NamespaceConnectionString, entityPath, receiveMode);
            }
            else
            {
                throw new NonExistentEntityException(String.Format("Subscription {0} does not exist in Topic {1}", SubscriptionName, TopicName));
            }
        }

        public IList<SbMessage> ReceiveMessages(int NumberOfMessages, SbReceiveTypes ReceiveType)
        {
            switch (ReceiveType)
            {
                case SbReceiveTypes.ReceiveAndKeep:
                    return this.PeekMessages(NumberOfMessages);

                case SbReceiveTypes.ReceiveAndDelete:
                    return this.ReceiveAndDelete(NumberOfMessages);

                default:
                    throw new NotImplementedException();
            }
        }

        private IList<SbMessage> PeekMessages(int NumberOfMessages)
        {
            IList<Message> messages = new List<Message>();

            for (int i = 0; i < NumberOfMessages; i++)
            {
                Message message = messageReceiver.PeekBySequenceNumberAsync((messageReceiver.LastPeekedSequenceNumber + 1)).Result;

                if (message != null)
                {
                    messages.Add(message);
                }
                else
                {
                    break;
                }
            }
            
            return BuildMessageList(messages);
        }

        private IList<SbMessage> ReceiveAndDelete(int NumberOfMessages)
        {
            IList<Message> messages = new List<Message>();

            for (int i = 0; i < NumberOfMessages; i++)
            {
                Message message = messageReceiver.ReceiveAsync().Result;

                if (message != null)
                {
                    messages.Add(message);
                    messageReceiver.CompleteAsync(message.SystemProperties.LockToken);
                }
                else
                {
                    break;
                }
            }

            return BuildMessageList(messages);
        }

        public void PurgeMessages()
        {
            try
            {
                IList<Message> res = null;

                do
                {
                    res = messageReceiver.ReceiveAsync(100,TimeSpan.FromSeconds(1)).Result;
                } while (res != null && res.Count > 0);
            }
            catch (Exception)
            {

                throw;
            }
        }

        private MessageReceiver CreateMessageReceiver(string NamespaceConnectionString, string EntityPath, ReceiveMode Mode)
        {
            MessageReceiver messageReceiver = new MessageReceiver(NamespaceConnectionString, EntityPath, Mode);
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
