[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Clear-SbQueue tests" {

    # setup

    # create some queues, topics and subscriptions and allow time for it to complete

    $queues = $ServiceBusUtils.CreateQueues(2)

    $testTopic = (New-Guid).Guid
    $ServiceBusUtils.CreateTopic($testTopic)

    $subscriptions = $ServiceBusUtils.CreateSubscriptions($testTopic, 2)

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

    Context "Test parameter attributes" {

        It "QueueName parameter should be mandatory" {
            (Get-Command -Name Clear-SbQueue).Parameters['QueueName'].Attributes.Mandatory | Should -Be $true
        }

        It "TopicName parameter should be mandatory" {
            (Get-Command -Name Clear-SbQueue).Parameters['TopicName'].Attributes.Mandatory | Should -Be $true
        }

        It "SubscriptionName parameter should be mandatory" {
            (Get-Command -Name Clear-SbQueue).Parameters['SubscriptionName'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Test clearing a queue" {

        It "should clear all messages" {
            $queue = $queues[0]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.ActiveMessageCount | Should -Be 0
        }

        It "should clear all messages from the dead letter queue if -DeadLetterQueue is supplied" {
            $queue = $queues[1]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -DeadLetterQueue
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.DeadLetterMessageCount | Should -Be 0
        }
    }

    Context "Test clearing a subscription" {

        It "should clear all messages" {
            $subscription = $subscriptions[0]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetSubscriptionRuntimeInfo($testTopic, $subscription).MessageCountDetails.ActiveMessageCount | Should -Be 0
        }

        It "should clear all messages from the dead letter queue if -DeadLetterQueue is supplied" {
            $subscription = $subscriptions[1]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription -DeadLetterQueue
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetSubscriptionRuntimeInfo($testTopic, $subscription).MessageCountDetails.DeadLetterMessageCount | Should -Be 0
        }
    }

    Context "Negative tests" {

        It "should throw correct exception message when a non-existent queue is supplied" {
            { Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName "non-existent" } | Should -Throw "Queue non-existent does not exist"
        }

        It "should throw correct exception message when a non-existent topic is supplied" {
            { Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName "non-existent" -SubscriptionName 'non-existent' } | Should -Throw "Subscription non-existent does not exist in Topic non-existent"
        }
    }

    # tear down

    foreach ($queue in $queues)
    {
        $ServiceBusUtils.RemoveQueue($queue)
    }

    $ServiceBusUtils.RemoveTopic($testTopic)
}