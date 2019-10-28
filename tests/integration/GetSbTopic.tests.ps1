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

    Start-Sleep -Seconds 5

    # tests

    Context "Test without -TopicName parameter" {

        $result = Get-SbTopic -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString

        It "should return all of the topics" {
            $result.count | Should -EQ $topics.count
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

    # tear down topics created for test

    foreach ($item in $topics)
    {
        $ServiceBusUtils.RemoveTopic($item.Topic)
    }
}
