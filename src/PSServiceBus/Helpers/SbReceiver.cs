﻿using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using PSServiceBus.Outputs;
using PSServiceBus.Enums;
using PSServiceBus.Exceptions;
using System.Management.Automation;

namespace PSServiceBus.Helpers
{
    public class SbReceiver
    {
        private readonly MessageReceiver messageReceiver;

        public SbReceiver(string NamespaceConnectionString, string QueueName, bool ReceiveFromDeadLetter, ISbManager sbManager)
        {
            if (sbManager.QueueOrTopicExists(QueueName, SbEntityTypes.Queue))
            {
                string entityPath = QueueName;

                if (ReceiveFromDeadLetter)
                {
                    entityPath = sbManager.BuildDeadLetterPath(QueueName);
                }

                this.messageReceiver = CreateMessageReceiver(NamespaceConnectionString, entityPath);
            }
            else
            {
                throw new NonExistentEntityException(String.Format("{0} {1} does not exist", SbEntityTypes.Queue, QueueName));
            }
        }

        public SbReceiver(string NamespaceConnectionString, string TopicName, string SubscriptionName, bool ReceiveFromDeadLetter, ISbManager sbManager)
        {
            if (sbManager.SubscriptionExists(TopicName, SubscriptionName))
            {
                string subscriptionPath = sbManager.BuildSubscriptionPath(TopicName, SubscriptionName);
                string entityPath = subscriptionPath;

                if (ReceiveFromDeadLetter)
                {
                    entityPath = sbManager.BuildDeadLetterPath(subscriptionPath);
                }

                this.messageReceiver = CreateMessageReceiver(NamespaceConnectionString, entityPath);
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
            IList<Message> messages = messageReceiver.PeekBySequenceNumberAsync(0, NumberOfMessages).Result;

            return BuildMessageList(messages);
        }

        private IList<SbMessage> ReceiveAndDelete(int NumberOfMessages)
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
