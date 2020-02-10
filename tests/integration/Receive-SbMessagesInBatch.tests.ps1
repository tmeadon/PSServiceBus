[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Receive-SbMessagesInBatch tests" {

    # setup

    # create some queues, topics and subscriptions and allow time for it to complete

    $queues = $ServiceBusUtils.CreateQueues(4)

    $testTopic = (New-Guid).Guid
    $ServiceBusUtils.CreateTopic($testTopic)

    $subscriptions = $ServiceBusUtils.CreateSubscriptions($testTopic, 4)

    # send some messages to the queues and the topic and dead letter a portion of them

    $messagesToSendToEachEntity = 5
    $messagesToDeadLetter = 2

    foreach ($queue in $queues)
    {
        for ($i = 0; $i -lt $messagesToSendToEachEntity; $i++)
        {
            $ServiceBusUtils.SendTestMessage($queue)
        }

        for ($i = 0; $i -lt $messagesToDeadLetter; $i++)
        {
            $ServiceBusUtils.ReceiveAndDeadLetterAMessage($queue)
        }
    }

    for ($i = 0; $i -lt $messagesToSendToEachEntity; $i++)
    {
        $ServiceBusUtils.SendTestMessage($testTopic)
    }
    
    foreach ($subscription in $subscriptions)
    {
        $subscriptionPath = $ServiceBusUtils.BuildSubscriptionPath($testTopic, $subscription)

        for ($i = 0; $i -lt $messagesToDeadLetter; $i++)
        {
            $ServiceBusUtils.ReceiveAndDeadLetterAMessage($subscriptionPath)
        }
    }

    # tests

    Context "Output type tests" {

        It "should have an output type of PSServiceBus.Outputs.SbMessage" {
            (Get-Command -Name "Receive-SbMessagesInBatch").OutputType.Name | Should -Be "PSServiceBus.Outputs.SbMessage" 
        }
        
    }

    Context "Test parameter attributes" {

        It "QueueName parameter should be mandatory" {
            (Get-Command -Name Receive-SbMessagesInBatch).Parameters['QueueName'].Attributes.Mandatory | Should -Be $true
        }

        It "TopicName parameter should be mandatory" {
            (Get-Command -Name Receive-SbMessagesInBatch).Parameters['TopicName'].Attributes.Mandatory | Should -Be $true
        }

        It "SubscriptionName parameter should be mandatory" {
            (Get-Command -Name Receive-SbMessagesInBatch).Parameters['SubscriptionName'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Test receiving from a queue" {

        It "should receive a single message if -ReceiveQty is not supplied" {
            $queue = $queues[0]
            $result = Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue
            $result.count | Should -Be 1
        }

        It "should receive the correct number of messages if -ReceiveQty is supplied" -TestCases @{messages = 2}, @{messages = 3} {
            param ([int] $messages)
            $queue = $queues[1]
            $result = Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -ReceiveQty $messages
            $result.count | Should -Be $messages
        }

        It "should leave messages in the queue after being received if -ReceiveType is not supplied" {
            $queue = $queues[2]
            Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -ReceiveQty 2
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.ActiveMessageCount | Should -Be ($messagesToSendToEachEntity - $messagesToDeadLetter)
        }

        It "should remove messages from the queue after being received if -ReceiveType ReceiveAndDelete is supplied" {
            $queue = $queues[2]
            $messagesToRemove = 2
            Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -ReceiveQty $messagesToRemove -ReceiveType ReceiveAndDelete
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.ActiveMessageCount | Should -Be ($messagesToSendToEachEntity - $messagesToDeadLetter - $messagesToRemove)
        }

        It "should receive messages from the dead letter queue if -ReceiveFromDeadLetterQueue is supplied" {
            $queue = $queues[3]
            $messagesToReceive = 1
            Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -ReceiveQty $messagesToReceive -ReceiveType ReceiveAndDelete -ReceiveFromDeadLetterQueue
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.DeadLetterMessageCount | Should -Be ($messagesToDeadLetter - $messagesToReceive)
        }
    }

    Context "Test receiving from a subscription" {

        It "should receive a single message if -ReceiveQty is not supplied" {
            $subscription = $subscriptions[0]
            $result = Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription
            $result.count | Should -Be 1
        }

        It "should receive the correct number of messages if -ReceiveQty is supplied" -TestCases @{messages = 2}, @{messages = 3} {
            param ([int] $messages)
            $subscription = $subscriptions[1]
            $result = Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription -ReceiveQty $messages
            $result.count | Should -Be $messages
        }

        It "should leave messages in the subscription after being received if -ReceiveType is not supplied" {
            $subscription = $subscriptions[2]
            Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription -ReceiveQty 2
            $ServiceBusUtils.GetSubscriptionRuntimeInfo($testTopic, $subscription).MessageCountDetails.ActiveMessageCount | Should -Be ($messagesToSendToEachEntity - $messagesToDeadLetter)
        }

        It "should remove messages from the subscription after being received if -ReceiveType ReceiveAndDelete is supplied" {
            $subscription = $subscriptions[2]
            $messagesToRemove = 2
            Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription -ReceiveQty $messagesToRemove -ReceiveType ReceiveAndDelete
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetSubscriptionRuntimeInfo($testTopic, $subscription).MessageCountDetails.ActiveMessageCount | Should -Be ($messagesToSendToEachEntity - $messagesToDeadLetter - $messagesToRemove)
        }

        It "should receive messages from the dead letter queue if -ReceiveFromDeadLetterQueue is supplied" {
            $subscription = $subscriptions[3]
            $messagesToReceive = 1
            Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription -ReceiveQty $messagesToReceive -ReceiveType ReceiveAndDelete -ReceiveFromDeadLetterQueue
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetSubscriptionRuntimeInfo($testTopic, $subscription).MessageCountDetails.DeadLetterMessageCount | Should -Be ($messagesToDeadLetter - $messagesToReceive)
        }
    }

    Context "Negative tests" {

        It "should throw correct exception message when a non-existent queue is supplied" {
            { Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName "non-existent" } | Should -Throw "Queue non-existent does not exist"
        }

        It "should throw correct exception message when a non-existent topic is supplied" {
            { Receive-SbMessagesInBatch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName "non-existent" -SubscriptionName 'non-existent' } | Should -Throw "Subscription non-existent does not exist in Topic non-existent"
        }
    }

    # tear down

    foreach ($queue in $queues)
    {
        $ServiceBusUtils.RemoveQueue($queue)
    }

    $ServiceBusUtils.RemoveTopic($testTopic)
}