[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Get-SbSubscription tests" {

    # setup

    # create some topics and subscriptions
    $topicsToCreate = 2
    $subscriptionsToCreatePerTopic = 2

    $topics = @()

    $ServiceBusUtils.CreateTopics($topicsToCreate) | ForEach-Object -Process {

        $topic = [PSCustomObject]@{
            TopicName = $_
            Subscriptions = $ServiceBusUtils.CreateSubscriptions($_, $subscriptionsToCreatePerTopic)
        }

        $topics += $topic
    }

    # send some messages to each topic and dead letter a portion
    $messagesToSendToEachQueue = 5
    $messagesToDeadLetter = 2

    foreach ($topic in $topics)
    {
        for ($i = 0; $i -lt $messagesToSendToEachQueue; $i++)
        {
            $ServiceBusUtils.SendTestMessage($topic.TopicName)
        }

        foreach ($subscription in $topic.Subscriptions)
        {
            $subscriptionPath = $ServiceBusUtils.BuildSubscriptionPath($topic.TopicName, $subscription)

            for ($i = 0; $i -lt $messagesToDeadLetter; $i++)
            {
                $ServiceBusUtils.ReceiveAndDeadLetterAMessage($subscriptionPath)
            }
        }
    }

    # tests

    Context "Pipeline input tests" {

        $result = $topics | Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString

        $testCases = @( foreach ($topic in $topics) { @{TopicName = $topic.TopicName} } ) 

        It "should return results for each TopicName piped in" -TestCases $testCases {
            param ([string] $topicName)
            $topicName | Should -BeIn $result.Topic
        }
    }

    Context "Test without -SubscriptionName parameter" {

        $testTopic = $topics[0]

        $result = Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic.TopicName
        
        It "should return all of the subscriptions in a topic" {
            $result.count | Should -Be $testTopic.Subscriptions.count
        }

        It "should return the correct number of active messages in all subscriptions" {
            foreach ($item in $result)
            {
                $item.ActiveMessages | Should -Be ($messagesToSendToEachQueue - $messagesToDeadLetter)
            }
        }

        It "should return the correct number of dead lettered messages in all subscriptions" {
            foreach ($item in $result)
            {
                $item.DeadLetteredMessages | Should -Be $messagesToDeadLetter
            }
        }
    }

    Context "Tests with -SubscriptionName parameter" {

        $testTopic = $topics[0]

        $testCases = @( foreach ($sub in $testTopic.Subscriptions) { @{Subscription = $sub} } )

        It "should return the correct subscription" -TestCases $testCases {
            param ([string] $subscription)
            $result = Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic.TopicName -SubscriptionName $subscription
            $result.Name | Should -Be $subscription
        }

        It "should return the correct number of active messages in a specific subscription" -TestCases $testCases {
            param ([string] $subscription)
            $result = Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic.TopicName -SubscriptionName $subscription
            $result.ActiveMessages | Should -Be ($messagesToSendToEachQueue - $messagesToDeadLetter)
        }

        It "should return the correct number of dead lettered messages in a specific subscription" -TestCases $testCases {
            param ([string] $subscription)
            $result = Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic.TopicName -SubscriptionName $subscription
            $result.DeadLetteredMessages | Should -Be $messagesToDeadLetter
        }
    }

    # tear down queues created for test

    foreach ($item in $topics)
    {
        $ServiceBusUtils.RemoveTopic($item.TopicName)
    }
}


