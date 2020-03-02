[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Clear-SbQueue tests" {

    # setup

    # create some queues, topics and subscriptions

    $queues = $ServiceBusUtils.CreateQueues(10)
    $queuesBatch = $ServiceBusUtils.CreateQueues(2)
    $testTopic = (New-Guid).Guid
    $ServiceBusUtils.CreateTopic($testTopic)
    $subscriptions = $ServiceBusUtils.CreateSubscriptions($testTopic, 10)
    $testTopicBatch = (New-Guid).Guid
    $ServiceBusUtils.CreateTopic($testTopicBatch)
    $subscriptionsBatch = $ServiceBusUtils.CreateSubscriptions($testTopicBatch, 1)

    # send some messages to the queues and the topic and dead letter a portion of them, also schedule some messages

    $messagesToSendToEachEntity = 5
    $messagesToDeadLetter = 2
    $messagesToSchedule = 3
    $enqueueMinutesIntoFuture = 10
    $enqueueDatetime = (Get-Date).AddMinutes($enqueueMinutesIntoFuture).ToUniversalTime()

    $messagesToSendInBatch = 200
    $batchReceiveQty = 5
    $batchPrefetchQty = 5
    $batchTimeout = 4

    foreach ($queue in $queues) {
        for ($i = 0; $i -lt $messagesToSendToEachEntity; $i++) {
            $ServiceBusUtils.SendTestMessage($queue)
        }

        for ($i = 0; $i -lt $messagesToDeadLetter; $i++) {
            $ServiceBusUtils.ReceiveAndDeadLetterAMessage($queue)
        }

        for ($i = 0; $i -lt $messagesToSchedule; $i++) {
            $ServiceBusUtils.ScheduleTestMessage($queue, $enqueueDatetime)
        }
    }

    for ($i = 0; $i -lt $messagesToSendToEachEntity; $i++) {
        $ServiceBusUtils.SendTestMessage($testTopic)
    }

    for ($i = 0; $i -lt $messagesToSchedule; $i++) {
        $ServiceBusUtils.ScheduleTestMessage($testTopic, $enqueueDatetime)
    }
    
    foreach ($subscription in $subscriptions) {
        $subscriptionPath = $ServiceBusUtils.BuildSubscriptionPath($testTopic, $subscription)

        for ($i = 0; $i -lt $messagesToDeadLetter; $i++) {
            $ServiceBusUtils.ReceiveAndDeadLetterAMessage($subscriptionPath)
        }
    }

    $batchMessages = [System.Collections.Generic.List[string]]@()
    
    for ($i = 0; $i -lt $messagesToSendInBatch; $i++) {
        $batchMessages.Add(([System.Guid]::NewGuid()).Guid)
    }

    foreach ($queue in $queuesBatch) {
        $ServiceBusUtils.SendMessagesInBatch($queue, $batchMessages.ToArray())
    }

    $ServiceBusUtils.SendMessagesInBatch($testTopicBatch, $batchMessages.ToArray())

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

        It "should clear all messages from the active queue by default" {
            $queue = $queues[0]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -Verbose:$false
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.ActiveMessageCount | Should -Be 0
        }

        It "should clear all messages from the dead letter queue if -DeadLetterQueue is supplied" {
            $queue = $queues[1]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -DeadLetterQueue -Verbose:$false
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.DeadLetterMessageCount | Should -Be 0
        }

        It "should return the output of Get-SbQueue if -NoOutput is not supplied" {
            $queue = $queues[2]
            $output = Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue
            $expectedOutput = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue
            Compare-Object -ReferenceObject $output -DifferenceObject $expectedOutput | Should -Be $null
        }

        It "should return no output if -NoOutput is supplied" {
            $queue = $queues[3]
            $output = Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -NoOutput
            $output | Should -Be $null
        }

        It "should close the receiver connection after purge, pumping new messages in the queue, should all be kept" {
            $queue = $queuesBatch[0]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -Verbose:$false
            Start-Sleep -Seconds 1
            $ServiceBusUtils.SendMessagesInBatch($queue, $batchMessages.ToArray())
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetQueueRuntimeInfo($queue).MessageCountDetails.ActiveMessageCount | Should -Be $messagesToSendInBatch
        }

        It "should fetch batches of $batchReceiveQty or less if -ReceiveBatchQty $batchReceiveQty is supplied" {
            $queue = $queuesBatch[1]
            $temp = @(Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -ReceiveBatchQty $batchReceiveQty -PrefetchQty $batchPrefetchQty -Verbose 4>&1)
            $counters = @($temp.Message | Where-Object { $_ -Like "Received Message Count:*" } | ForEach-Object { [int]$_.Replace("Received Message Count: ", "") })
            $counters -gt $batchReceiveQty | Should -BeNullOrEmpty
        }

        It "should wait at least the number of seconds specified with the -TimeoutInSeconds $batchTimeout" {
            #reusing the previous on purpose. We need an empty queue, to make the wait as close as possible
            $queue = $queuesBatch[1]
            $temp = Measure-Command { Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queue -ReceiveBatchQty $batchReceiveQty -PrefetchQty $batchPrefetchQty -TimeoutInSeconds $batchTimeout }
            $([System.Double]::Parse($temp.TotalSeconds)) | Should -BeGreaterThan $([System.Double]::Parse($batchTimeout))
        }

        # define some test cases for testing the -QueueStores parameter
        $testCases = @(
            @{
                testQueue = $queues[4]
                queueStoreParamValue = 'Active'
                expectedActiveCount = 0
                expectedDeadLetterCount = $messagesToDeadLetter
                expectedScheduledCount = $messagesToSchedule
            },
            @{
                testQueue = $queues[5]
                queueStoreParamValue = 'DeadLetter'
                expectedActiveCount = $messagesToSendToEachEntity - $messagesToDeadLetter
                expectedDeadLetterCount = 0
                expectedScheduledCount = $messagesToSchedule
            },
            @{
                testQueue = $queues[6]
                queueStoreParamValue = 'Scheduled'
                expectedActiveCount = $messagesToSendToEachEntity - $messagesToDeadLetter
                expectedDeadLetterCount = $messagesToDeadLetter
                expectedScheduledCount = 0
            },
            @{
                testQueue = $queues[7]
                queueStoreParamValue = 'All'
                expectedActiveCount = 0
                expectedDeadLetterCount = 0
                expectedScheduledCount = 0
            },
            @{
                testQueue = $queues[8]
                queueStoreParamValue = 'Active', 'DeadLetter'
                expectedActiveCount = 0
                expectedDeadLetterCount = 0
                expectedScheduledCount = $messagesToSchedule
            }
        )

        It "should empty the correct queue stores when -QueueStores is supplied" -TestCases $testCases {
            param ([string]$testQueue, [string[]]$queueStoreParamValue, [int]$expectedActiveCount, [int]$expectedDeadLetterCount, [int]$expectedScheduledCount)
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $testQueue -QueueStores $queueStoreParamValue
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $testQueue
            $result.ActiveMessages | Should -Be $expectedActiveCount
            $result.DeadLetteredMessages | Should -Be $expectedDeadLetterCount
            $result.ScheduledMessageCount | Should -Be $expectedScheduledCount
        }
    }

    Context "Test clearing a subscription" {

        It "should clear all messages" {
            $subscription = $subscriptions[0]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription -Verbose:$false
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetSubscriptionRuntimeInfo($testTopic, $subscription).MessageCountDetails.ActiveMessageCount | Should -Be 0
        }

        It "should clear all messages from the dead letter queue if -DeadLetterQueue is supplied" {
            $subscription = $subscriptions[1]
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription -DeadLetterQueue -Verbose:$false
            Start-Sleep -Seconds 1
            $ServiceBusUtils.GetSubscriptionRuntimeInfo($testTopic, $subscription).MessageCountDetails.DeadLetterMessageCount | Should -Be 0
        }

        It "should return the output of Get-SbSubscription if -NoOutput is not supplied" {
            $subscription = $subscriptions[2]
            $output = Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription
            $expectedOutput = Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription
            Compare-Object -ReferenceObject $output -DifferenceObject $expectedOutput | Should -Be $null
        }

        It "should return no output if -NoOutput is supplied" {
            $subscription = $subscriptions[3]
            $output = Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $subscription -NoOutput
            $output | Should -Be $null
        }

        It "should fetch batches of $batchReceiveQty or less if -ReceiveBatchQty $batchReceiveQty is supplied" {
            $subscription = $subscriptionsBatch[0]
            $temp = @(Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopicBatch -SubscriptionName $subscription -ReceiveBatchQty $batchReceiveQty -PrefetchQty $batchPrefetchQty -Verbose 4>&1)
            $counters = @($temp.Message | Where-Object { $_ -Like "Received Message Count:*" } | ForEach-Object { [int]$_.Replace("Received Message Count: ", "") })
            $counters -gt $batchReceiveQty | Should -BeNullOrEmpty
        }

        It "should wait at least the number of seconds specified with the -TimeoutInSeconds $batchTimeout" {
            #reusing the previous on purpose. We need an empty queue, to make the wait as close as possible
            $subscription = $subscriptionsBatch[0]
            $temp = Measure-Command { Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopicBatch -SubscriptionName $subscription -ReceiveBatchQty $batchReceiveQty -PrefetchQty $batchPrefetchQty -TimeoutInSeconds $batchTimeout }
            $([System.Double]::Parse($temp.TotalSeconds)) | Should -BeGreaterThan $([System.Double]::Parse($batchTimeout))
        }

        # define some test cases for testing the -QueueStores parameter
        $testCases = @(
            @{
                testSub = $subscriptions[4]
                queueStoreParamValue = 'Active'
                expectedActiveCount = 0
                expectedDeadLetterCount = $messagesToDeadLetter
            },
            @{
                testSub = $subscriptions[5]
                queueStoreParamValue = 'DeadLetter'
                expectedActiveCount = $messagesToSendToEachEntity - $messagesToDeadLetter
                expectedDeadLetterCount = 0
            },
            @{
                testSub = $subscriptions[6]
                queueStoreParamValue = 'Scheduled'
                expectedActiveCount = $messagesToSendToEachEntity - $messagesToDeadLetter
                expectedDeadLetterCount = $messagesToDeadLetter
            },
            @{
                testSub = $subscriptions[7]
                queueStoreParamValue = 'All'
                expectedActiveCount = 0
                expectedDeadLetterCount = 0
            },
            @{
                testSub = $subscriptions[8]
                queueStoreParamValue = 'Active', 'DeadLetter'
                expectedActiveCount = 0
                expectedDeadLetterCount = 0
            }
        )

        It "should empty the correct queue stores when -QueueStores is supplied" -TestCases $testCases {
            param ([string]$testSub, [string[]]$queueStoreParamValue, [int]$expectedActiveCount, [int]$expectedDeadLetterCount)
            Clear-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $testSub -QueueStores $queueStoreParamValue
            $result = Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -TopicName $testTopic -SubscriptionName $testSub
            $result.ActiveMessages | Should -Be $expectedActiveCount
            $result.DeadLetteredMessages | Should -Be $expectedDeadLetterCount
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

    foreach ($queue in $queues) {
        $ServiceBusUtils.RemoveQueue($queue)
    }

    foreach ($queue in $queuesBatch) {
        $ServiceBusUtils.RemoveQueue($queue)
    }

    $ServiceBusUtils.RemoveTopic($testTopic)
    
    $ServiceBusUtils.RemoveTopic($testTopicBatch)
}