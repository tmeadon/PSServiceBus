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

        $expectedQueueProperties = @()
        
        foreach ($item in $result)
        {
            $expectedQueueProperties += @{
                Name = $item.Name
                Properties = $ServiceBusUtils.GetQueue($item.Name)
                QueueRuntimeInfo = $ServiceBusUtils.GetQueueRuntimeInfo($item.Name)
            }
        }

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

        It "should return the correct value for DefaultMessageTtlInDays" {
            foreach ($item in $result)
            {
                $item.DefaultMessageTtlInDays | Should -EQ $expectedQueueProperties.Where({$_.Name -eq $item.Name}).Properties.DefaultMessageTimeToLive
            }
        }

        It "should return the correct value for LockDuration" {
            foreach ($item in $result)
            {
                $item.LockDuration | Should -EQ $expectedQueueProperties.Where({$_.Name -eq $item.Name}).Properties.LockDuration
            }
        }

        It "should return the correct value for DuplicateDetectionHistoryTimeWindow" {
            foreach ($item in $result)
            {
                $item.DuplicateDetectionHistoryTimeWindow | Should -EQ $expectedQueueProperties.Where({$_.Name -eq $item.Name}).Properties.DuplicateDetectionHistoryTimeWindow
            }
        }

        It "should return the correct value for MaxDeliveryCount" {
            foreach ($item in $result)
            {
                $item.MaxDeliveryCount | Should -EQ $expectedQueueProperties.Where({$_.Name -eq $item.Name}).Properties.MaxDeliveryCount
            }
        }

        It "should return the correct value for EnableBatchedOperations" {
            foreach ($item in $result)
            {
                $item.EnableBatchedOperations | Should -EQ $expectedQueueProperties.Where({$_.Name -eq $item.Name}).Properties.EnableBatchedOperations
            }
        }
        
        It "should return the correct value for MaxSizeInMB" {
            foreach ($item in $result)
            {
                $item.MaxSizeInMB | Should -EQ $expectedQueueProperties.Where({$_.Name -eq $item.Name}).Properties.MaxSizeInMB
            }
        }

        It "should return the correct value for CurrentSizeInMB" {
            foreach ($item in $result)
            {
                $item.CurrentSizeInMB | Should -EQ ([int]($expectedQueueProperties.Where({$_.Name -eq $item.Name}).QueueRuntimeInfo.SizeInBytes / 1000000))
            }
        }

        It "should return the correct value for Status" {
            foreach ($item in $result)
            {
                $item.Status | Should -EQ $expectedQueueProperties.Where({$_.Name -eq $item.Name}).Properties.Status.ToString()
            }
        }

        It "should return the correct value for PercentageCapacityFree" {
            foreach ($item in $result)
            {
                $item.PercentageCapacityFree | Should -EQ ((($item.MaxSizeInMB - $item.CurrentSizeInMB) / $item.MaxSizeInMB) * 100)
            }
        }
    }

    Context "Tests with -QueueName parameter" {

        $testCases = @(
            @{
                queueName = $newQueues[0]
                Properties = $ServiceBusUtils.GetQueue($newQueues[0])
                QueueRuntimeInfo = $ServiceBusUtils.GetQueueRuntimeInfo($newQueues[0])
            },
            @{
                queueName = $newQueues[1]
                Properties = $ServiceBusUtils.GetQueue($newQueues[1])
                QueueRuntimeInfo = $ServiceBusUtils.GetQueueRuntimeInfo($newQueues[1])
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

        It "should return the correct value for DefaultMessageTtlInDays" -TestCases $testCases {
            param ([string] $queueName, [object] $properties)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.DefaultMessageTtlInDays | Should -EQ $properties.DefaultMessageTimeToLive
        }

        It "should return the correct value for LockDuration" -TestCases $testCases {
            param ([string] $queueName, [object] $properties)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.LockDuration | Should -EQ $properties.LockDuration
        }

        It "should return the correct value for DuplicateDetectionHistoryTimeWindow" -TestCases $testCases {
            param ([string] $queueName, [object] $properties)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.DuplicateDetectionHistoryTimeWindow | Should -EQ $properties.DuplicateDetectionHistoryTimeWindow
        }

        It "should return the correct value for MaxDeliveryCount" -TestCases $testCases {
            param ([string] $queueName, [object] $properties)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.MaxDeliveryCount | Should -EQ $properties.MaxDeliveryCount
        }

        It "should return the correct value for EnableBatchedOperations" -TestCases $testCases {
            param ([string] $queueName, [object] $properties)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.EnableBatchedOperations | Should -EQ $properties.EnableBatchedOperations
        }
        
        It "should return the correct value for MaxSizeInMB" -TestCases $testCases {
            param ([string] $queueName, [object] $properties)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.MaxSizeInMB | Should -EQ $properties.MaxSizeInMB
        }

        It "should return the correct value for CurrentSizeInMB" -TestCases $testCases {
            param ([string] $queueName, [object] $queueRuntimeInfo)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.CurrentSizeInMB | Should -EQ ([int]($queueRuntimeInfo.QueueRuntimeInfo.SizeInBytes / 1000000))
        }

        It "should return the correct value for Status" -TestCases $testCases {
            param ([string] $queueName, [object] $properties)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.Status | Should -EQ $properties.Status.ToString()
        }

        It "should return the correct value for PercentageCapacityFree" -TestCases $testCases {
            param ([string] $queueName, [object] $queueRuntimeInfo)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.PercentageCapacityFree | Should -EQ ((($result.MaxSizeInMB - $result.CurrentSizeInMB) / $result.MaxSizeInMB) * 100)
        }
    }

    # tear down queues created for test

    foreach ($item in $newQueues)
    {
        $ServiceBusUtils.RemoveQueue($item)
    }
}
