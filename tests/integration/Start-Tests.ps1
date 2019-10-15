[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $TestServiceBusConnectionString
)

Import-Module -Name Pester -RequiredVersion 4.9.0
Import-Module $PSScriptRoot\..\..\output\PSServiceBus\PSServiceBus.psd1
Import-Module $PSScriptRoot\..\utils\PSServiceBus.Tests.Utils\bin\Release\netstandard2.0\PSServiceBus.Tests.Utils.dll
$sbUtils = [PSServiceBus.Tests.Utils.ServiceBusUtils]::new($TestServiceBusConnectionString)

Invoke-Pester -Script @{
    Path = "$PSScriptRoot\GetSbQueue.tests.ps1"
    Parameters = @{
        ServiceBusUtils = $sbUtils
    }
}
