[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Get-SbQueue tests" {

    Context "Parameter tests" {

        # setup 
        
        # create some queues
        $createdQueues = @()
        
        for ($i = 0; $i -lt 4; $i++)
        {
            $guid = (New-Guid).Guid
            $createdQueues += $guid
            $ServiceBusUtils.CreateQueue($guid)
        }

        # wait for the creation to complete
        Start-Sleep -Seconds 5

        # retrieve all the queues
        $existingQueues = $ServiceBusUtils.GetAllQueues();

        # tests

        It "should return all of the queues if -QueueName parameter is not specified" {  
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString
            $result.count | Should -EQ $existingQueues.count
        }

        $testCases = @(
            @{
                queueName = $existingQueues[0].Path
            }
            @{
                queueName = $existingQueues[1].Path
            }
        )

        It "should return the correct queue if -QueueName parameter is specifed" -TestCases $testCases {
            param ([string] $queueName)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.Name | Should -Be $queueName
        }

        # teardown
        foreach ($item in $createdQueues)
        {
            $ServiceBusUtils.RemoveQueue($item)
        }
    }
}
