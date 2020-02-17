[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Get-SbQueue tests" {

    # setup

    # create some queues and wait for the creation to take place
    $newQueues = $ServiceBusUtils.CreateQueues(4)

    # send some messages to each queue and dead letter a portion
    $messagesToSendToEachQueue = 5
    $messagesToDeadLetter = 2
    $messagesToScheduleToEachEntity = 4
    $enqueueMinutesIntoFuture = 10

    $enqueueDatetime = (Get-Date).AddMinutes($enqueueMinutesIntoFuture).ToUniversalTime()

    for ($i = 0; $i -lt $newQueues.Count; $i++)
    {
        for ($j = 0; $j -lt $messagesToSendToEachQueue; $j++)
        {
            $ServiceBusUtils.SendTestMessage($newQueues[$i])
        }

        for ($j = 0; $j -lt $messagesToDeadLetter; $j++)
        {
            $ServiceBusUtils.ReceiveAndDeadLetterAMessage($newQueues[$i])
        }

        for ($j = 0; $j -lt $messagesToScheduleToEachEntity; $j++)
        {
            $ServiceBusUtils.ScheduleTestMessage($newQueues[$i], $enqueueDatetime)
        }
    }

    # allow time for scheduled messages to send
    Start-Sleep -Seconds 5

    # tests

    Context "Output type tests" {

        It "should have an output type of PSServiceBus.Outputs.SbQueue" {
            (Get-Command -Name "Get-SbQueue").OutputType.Name | Should -Be "PSServiceBus.Outputs.SbQueue"
        }
        
    }

    Context "Test without -QueueName parameter" {

        $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString

        It "should return all of the queues if -QueueName parameter is not specified" {
            $result.count | Should -EQ $newQueues.count
        }

        It "should return the correct number of active messages in all queues" {
            foreach ($item in $result)
            {
                $item.ActiveMessages | Should -EQ ($messagesToSendToEachQueue - $messagesToDeadLetter)
            }
        }

        It "should return the correct number of dead lettered messages in all queues" {
            foreach ($item in $result)
            {
                $item.DeadLetteredMessages | Should -EQ $messagesToDeadLetter
            }
        }

        It "should return the correct number of scheduled messages in all queues" {
            foreach ($item in $result)
            {
                $item.ScheduledMessageCount | Should -EQ $messagesToScheduleToEachEntity
            }
        }
    }

    Context "Tests with -QueueName parameter" {

        $testCases = @(
            @{
                queueName = $newQueues[0]
            },
            @{
                queueName = $newQueues[1]
            }
        )

        It "should return the correct queue" -TestCases $testCases {
            param ([string] $queueName)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.Name | Should -Be $queueName
        }

        It "should return the correct number of active messages in a specific queue" -TestCases $testCases {
            param ([string] $queueName)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.ActiveMessages | Should -EQ ($messagesToSendToEachQueue - $messagesToDeadLetter)
        }

        It "should return the correct number of dead lettered messages in a specific queue" -TestCases $testCases {
            param ([string] $queueName)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.DeadLetteredMessages | Should -EQ $messagesToDeadLetter
        }

        It "should return the correct number of scheduled messages in a specific queue" -TestCases $testCases {
            param ([string] $queueName)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.ScheduledMessageCount | Should -EQ $messagesToScheduleToEachEntity
        }
    }

    # tear down queues created for test

    foreach ($item in $newQueues)
    {
        $ServiceBusUtils.RemoveQueue($item)
    }
}
