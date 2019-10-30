[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Receive-SbMessage tests" {

    # create some queues, topics and subscriptions and allow time for it to complete 

    $queues = $ServiceBusUtils.CreateQueues(4)

    $testTopic = (New-Guid).Guid
    $ServiceBusUtils.CreateTopic($testTopic)

    Start-Sleep -Seconds 5

    $subscriptions = $ServiceBusUtils.CreateSubscriptions($testTopic, 4)

    Start-Sleep -Seconds 5

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

    Context "Test parameter attributes" {

        It "QueueName parameter should be mandatory" {
            (Get-Command -Name Receive-SbMessage).Parameters['QueueName'].Attributes.Mandatory | Should -Be $true
        }

        It "TopicName parameter should be mandatory" {
            (Get-Command -Name Receive-SbMessage).Parameters['TopicName'].Attributes.Mandatory | Should -Be $true
        }

        It "SubscriptionName parameter should be mandatory" {
            (Get-Command -Name Receive-SbMessage).Parameters['SubscriptionName'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Test receiving from a queue" {

        It "should receive a single message if -NumberOfMessagesToRetrieve is not supplied" {
            $queue = $queues[0]
            $result = Receive-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue
            $result.count | Should -Be 1
        }

        It "should receive the correct number of messages if -NumberOfMessagesToRetrieve is supplied" -TestCases @{messages = 2}, @{messages = 3} {
            param ([int] $messages)
            $queue = $queues[1]
            $result = Receive-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -NumberOfMessagesToRetrieve $messages
            $result.count | Should -Be $messages
        }

        It "should leave messages in the queue after being received if -ReceiveType is not supplied" {
            $queue = $queues[2]
            Receive-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -NumberOfMessagesToRetrieve 2
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.ActiveMessageCount | Should -Be ($messagesToSendToEachEntity - $messagesToDeadLetter)
        }

        It "should remove messages from the queue after being received if -ReceiveType ReceiveAndDelete is supplied" {
            $queue = $queues[2]
            $messagesToRemove = 2
            Receive-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -NumberOfMessagesToRetrieve $messagesToRemove -ReceiveType ReceiveAndDelete
            start-sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.ActiveMessageCount | Should -Be ($messagesToSendToEachEntity - $messagesToDeadLetter - $messagesToRemove)
        }

        It "should receive messages from the dead letter queue if -ReceiveFromDeadLetterQueue is supplied" {
            $queue = $queues[3]
            $messagesToReceive = 1
            Receive-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -NumberOfMessagesToRetrieve $messagesToReceive -ReceiveType ReceiveAndDelete -ReceiveFromDeadLetterQueue
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.DeadLetterMessageCount | Should -Be ($messagesToDeadLetter - $messagesToReceive)
        }
    }

    Context "Test receiving from a subscription" {

        It "should receive a single message if -NumberOfMessagesToRetrieve is not supplied" {

        }

        It "should receive the correct number of messages if -NumberOfMessagesToRetrieve is supplied" {

        }

        It "should leave messages in the subscription after being received if -ReceiveType is not supplied" {

        }

        It "should remove messages from the subscription after being received if -ReceiveType ReceiveAndDelete is supplied" {

        }

        It "should receive messages from the dead letter queue if -ReceiveFromDeadLetterQueue is supplied" {

        }
    }

    Context "Negative tests" {

        It "should throw correct exception message when a non-existent queue is supplied" {
            { Receive-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName "non-existent" } | Should -Throw "Queue non-existent does not exist"
        }

        It "should throw correct exception message when a non-existent topic is supplied" {
            { Receive-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName "non-existent" -SubscriptionName 'non-existent' } | Should -Throw "Subscription non-existent does not exist in Topic non-existent"
        }
    }

    # tear down

    foreach ($queue in $queues)
    { 
        $ServiceBusUtils.RemoveQueue($queue)
    }

    $ServiceBusUtils.RemoveTopic($testTopic)
}