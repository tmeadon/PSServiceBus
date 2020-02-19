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

    Context "Output type tests" {

        It "should have an output type of PSServiceBus.Outputs.SbSubscription" {
            (Get-Command -Name "Get-SbSubscription").OutputType.Name | Should -Be "PSServiceBus.Outputs.SbSubscription" 
        }
    
    }


    Context "Test without -SubscriptionName parameter" {

        $testTopic = $topics[0]

        $result = Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic.TopicName

        $expectedSubscriptionProperties = @()

        foreach ($item in $result)
        {
            $expectedSubscriptionProperties += @{
                Name = $item.Name
                Properties = $ServiceBusUtils.GetSubscription($testTopic.TopicName, $item.Name)
            }
        }
        
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

        It "should return the correct value for DefaultMessageTtlInDays" {
            foreach ($item in $result)
            {
                $item.DefaultMessageTtlInDays | Should -EQ $expectedSubscriptionProperties.Where({$_.Name -eq $item.Name}).Properties.DefaultMessageTimeToLive
            }
        }

        It "should return the correct value for LockDuration" {
            foreach ($item in $result)
            {
                $item.LockDuration | Should -EQ $expectedSubscriptionProperties.Where({$_.Name -eq $item.Name}).Properties.LockDuration
            }
        }

        It "should return the correct value for MaxDeliveryCount" {
            foreach ($item in $result)
            {
                $item.MaxDeliveryCount | Should -EQ $expectedSubscriptionProperties.Where({$_.Name -eq $item.Name}).Properties.MaxDeliveryCount
            }
        }

        It "should return the correct value for EnableBatchedOperations" {
            foreach ($item in $result)
            {
                $item.EnableBatchedOperations | Should -EQ $expectedSubscriptionProperties.Where({$_.Name -eq $item.Name}).Properties.EnableBatchedOperations
            }
        }

        It "should return the correct value for Status" {
            foreach ($item in $result)
            {
                $item.Status | Should -EQ $expectedSubscriptionProperties.Where({$_.Name -eq $item.Name}).Properties.Status.ToString()
            }
        }
    }

    Context "Tests with -SubscriptionName parameter" {

        $testTopic = $topics[0]

        $testCases = @( foreach ($sub in $testTopic.Subscriptions) { @{
            Subscription = $sub
            Result = Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic.TopicName -SubscriptionName $sub
            Properties = $ServiceBusUtils.GetSubscription($testTopic.TopicName, $sub)
        } } )

        It "should return the correct subscription" -TestCases $testCases {
            param ([string] $subscription, [object] $result)
            $result.Name | Should -Be $subscription
        }

        It "should return the correct number of active messages in a specific subscription" -TestCases $testCases {
            param ([string] $subscription, [object] $result)
            $result.ActiveMessages | Should -Be ($messagesToSendToEachQueue - $messagesToDeadLetter)
        }

        It "should return the correct number of dead lettered messages in a specific subscription" -TestCases $testCases {
            param ([string] $subscription, [object] $result)
            $result.DeadLetteredMessages | Should -Be $messagesToDeadLetter
        }

        It "should return the correct value for DefaultMessageTtlInDays" -TestCases $testCases {
            param ([string] $subscription, [object] $result, [object] $properties)
            $result.DefaultMessageTtlInDays | Should -EQ $properties.DefaultMessageTimeToLive
        }

        It "should return the correct value for LockDuration" -TestCases $testCases {
            param ([string] $subscription, [object] $result, [object] $properties)
            $result.LockDuration | Should -EQ $properties.LockDuration
        }

        It "should return the correct value for MaxDeliveryCount" -TestCases $testCases {
            param ([string] $subscription, [object] $result, [object] $properties)
            $result.MaxDeliveryCount | Should -EQ $properties.MaxDeliveryCount
        }

        It "should return the correct value for EnableBatchedOperations" -TestCases $testCases {
            param ([string] $subscription, [object] $result, [object] $properties)
            $result.EnableBatchedOperations | Should -EQ $properties.EnableBatchedOperations
        }

        It "should return the correct value for Status" -TestCases $testCases {
            param ([string] $subscription, [object] $result, [object] $properties)
            $result.Status | Should -EQ $properties.Status.ToString()
        }

    }

    # tear down queues created for test

    foreach ($item in $topics)
    {
        $ServiceBusUtils.RemoveTopic($item.TopicName)
    }
}


