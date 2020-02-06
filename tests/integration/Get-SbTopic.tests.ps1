[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Get-SbTopic tests" {

    # setup

    # create some topics and subscriptions
    $topicsToCreate = 2
    $subscriptionsToCreatePerTopic = 2

    $topics = @()

    $ServiceBusUtils.CreateTopics($topicsToCreate) | ForEach-Object -Process {

        $topic = [PSCustomObject]@{
            Topic = $_
            Subscriptions = $ServiceBusUtils.CreateSubscriptions($_, $subscriptionsToCreatePerTopic)
        }

        $topics += $topic
    }

    $messagesToScheduleToEachEntity = 4
    $enqueueMinutesIntoFuture = 10

    $enqueueDatetime = (Get-Date).AddMinutes($enqueueMinutesIntoFuture).ToUniversalTime()

    foreach ($topic in $topics)
    {
        for ($i = 0; $i -lt $messagesToScheduleToEachEntity; $i++)
        {
            $ServiceBusUtils.ScheduleTestMessage($topic.Topic, $enqueueDatetime)
        }
    }

    # tests

    Context "Output type tests" {

        It "should have an output type of PSServiceBus.Outputs.SbTopic" {
            (Get-Command -Name "Get-SbTopic").OutputType.Name | Should -Be "PSServiceBus.Outputs.SbTopic"
        }
        
    }

    Context "Test without -TopicName parameter" {

        $result = Get-SbTopic -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString

        It "should return all of the topics" {
            $result.count | Should -Be $topics.count
        }

        It "should return the correct number of subscriptions in each topic" {
            foreach ($item in $result)
            {
                $item.Subscriptions.count | Should -Be $topics.Where({$_.Topic -eq $item.TopicName}).Subscriptions.count
            }
        }

        It "should return the correct number of scheduled messages in each topic" {
            foreach ($item in $result)
            {
                $item.ScheduledMessages | Should -Be $messagesToScheduleToEachEntity
            }
        }

        It "should return the correct subscriptions in each topic" {
            foreach ($item in $result)
            {
                for ($i = 0; $i -lt $subscriptionsToCreatePerTopic; $i++)
                {
                    $item.Subscriptions[$i] | Should -BeIn $topics.Where({$_.Topic -eq $item.TopicName}).Subscriptions
                }
            }
        }
    }

    Context "Test with -TopicName parameter" {

        $testCases = @(
            @{
                topic = $topics[0]
            },
            @{
                topic = $topics[1]
            }
        )

        It "should return the correct topic" -TestCases $testCases {
            param ([PSCustomObject] $topic)
            $result = Get-SbTopic -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $topic.Topic
            $result.TopicName | Should -Be $topic.Topic
        }

        It "should return the correct number of subscriptions in a topic" -TestCases $testCases {
            param ([PSCustomObject] $topic)
            $result = Get-SbTopic -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $topic.Topic
            $result.Subscriptions.count | Should -Be $topic.Subscriptions.count
        }

        It "should return the correct number of scheduled messages in a topic" -TestCases $testCases {
            param ([PSCustomObject] $topic)
            $result = Get-SbTopic -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $topic.Topic
            $result.ScheduledMessages | Should -Be $messagesToScheduleToEachEntity
        }

        It "should return the correct subscriptions in a topic" -TestCases $testCases {
            param ([PSCustomObject] $topic)
            $result = Get-SbTopic -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $topic.Topic
            for ($i = 0; $i -lt $subscriptionsToCreatePerTopic; $i++)
            {
                $result.Subscriptions[$i] | Should -BeIn $topic.Subscriptions
            }
        }
    }

    # tear down topics created for test

    foreach ($item in $topics)
    {
        $ServiceBusUtils.RemoveTopic($item.Topic)
    }
}
