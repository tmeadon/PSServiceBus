[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Send-SbMessage tests" {

    # setup

    # create some queues, topics and subscriptions and allow time for it to complete 

    $testQueue = (New-Guid).Guid
    $ServiceBusUtils.CreateQueue($testQueue)

    $testTopic = (New-Guid).Guid
    $ServiceBusUtils.CreateTopic($testTopic)

    $testSubscription = (New-Guid).Guid
    $ServiceBusUtils.CreateSubscription($testTopic, $testSubscription)

    $testMessage = (New-Guid).Guid

    Start-Sleep -Seconds 5

    # send a test message to the test queue and the test topic and allow time to complete

    Send-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $testQueue -Message $testMessage
    Send-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -Message $testMessage

    Start-Sleep -Seconds 5

    Context "Test parameter attributes" {

        It "QueueName parameter should be mandatory" {
            (Get-Command -Name Send-SbMessage).Parameters['QueueName'].Attributes.Mandatory | Should -Be $true
        }

        It "TopicName parameter should be mandatory" {
            (Get-Command -Name Send-SbMessage).Parameters['TopicName'].Attributes.Mandatory | Should -Be $true
        }

        It "Message parameter should be mandatory" {
            (Get-Command -Name Send-SbMessage).Parameters['Message'].Attributes.Mandatory | Should -Be $true
        }
    }

    Context "Test sending to queue" {

        It "should send a single message to the correct queue" {
            $ServiceBusUtils.GetQueueRuntimeInfo($testQueue).MessageCountDetails.ActiveMessageCount | Should -Be 1
        }

        It "should send a message with the correct body" {
            $ServiceBusUtils.ReceiveAndCompleteAMessage($testQueue) | Should -Be $testMessage
        }
    }

    Context "Test sending to topic" {

        It "should send a single message to the correct topic" {
            $ServiceBusUtils.GetSubscriptionRuntimeInfo($testTopic, $testSubscription).MessageCountDetails.ActiveMessageCount | Should -Be 1
        }

        It "should send a message with the correct body" {
            $testSubscriptionPath = $ServiceBusUtils.BuildSubscriptionPath($testTopic, $testSubscription)
            $ServiceBusUtils.ReceiveAndCompleteAMessage($testSubscriptionPath) | Should -Be $testMessage
        }
    }

    Context "Negative tests" {

        It "should throw correct exception message when a non-existent queue is supplied" {
            { Send-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName "non-existent" -Message $testMessage } | Should -Throw "Queue non-existent does not exist"
        }

        It "should throw correct exception message when a non-existent topic is supplied" {
            { Send-SbMessage -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName "non-existent" -Message $testMessage } | Should -Throw "Topic non-existent does not exist"
        }
    }

    $ServiceBusUtils.RemoveQueue($testQueue)
    $ServiceBusUtils.RemoveTopic($testTopic)
}