[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Test-SbConnectionString tests" {

    It "should return false when an invalid connection string is supplied" {
        Test-SbConnectionString -NamespaceConnectionString 'invalid' | Should -Be $false
    }

    It "should return true when a valid connection string is supplied" {
        Test-SbConnectionString -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString | Should -Be $true
    }
}
