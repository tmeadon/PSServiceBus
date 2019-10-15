[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Testing Get-SbQueue" {

    for ($i = 0; $i -lt 4; $i++)
    {
        $ServiceBusUtils.CreateQueue((New-Guid).Guid)
    }

    Start-Sleep -Seconds 2

    $existingQueues = $ServiceBusUtils.GetAllQueues();

    It "should return all of the queues if -QueueName parameter is not specified" {  
        $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString
        $result.count | Should -EQ $existingQueues.count
    }
}