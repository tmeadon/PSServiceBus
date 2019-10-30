[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Save-SbConnectionString tests" {

    Save-SbConnectionString -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString

    $module = Get-Module -Name "PSServiceBus" | Where-Object -FilterScript {$_.ModuleType -eq "Script"}
    $commands = $Module.ExportedCommands.GetEnumerator()  | Select-Object -ExpandProperty value | Select-Object -ExpandProperty name

    foreach ($command in $commands)
    {
        It "should set the default value of the NamespaceConnectionString parameter for $command" {
            $Global:PSDefaultParameterValues["$command`:NamespaceConnectionString"] | Should -Be $ServiceBusUtils.NamespaceConnectionString
        }
    }
    
    It "should throw the correct error when called with an invalid connection string" {
        { Save-SbConnectionString -NamespaceConnectionString "invalid" } | Should -Throw "Unable to save connection string.  Exception: Testing connection string was unsuccessful."
    }
}