[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Get-SbQueue tests" {

    Context "Parameter tests" {

        # setup 

        $newQueues = $ServiceBusUtils.CreateQueues(4)
        Start-Sleep -Seconds 5
        $allQueues = $ServiceBusUtils.GetAllQueues();

        # tests

        It "should return all of the queues if -QueueName parameter is not specified" {  
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString
            $result.count | Should -EQ $allQueues.count
        }

        It "should return the correct queue if -QueueName parameter is specifed" -TestCases @{queueName = $newQueues[0]}, @{queueName = $newQueues[1]} {
            param ([string] $queueName)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.Name | Should -Be $queueName
        }

        # teardown

        foreach ($item in $newQueues)
        {
            $ServiceBusUtils.RemoveQueue($item)
        }
    }
}
