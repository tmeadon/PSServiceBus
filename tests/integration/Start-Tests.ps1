[CmdletBinding()]
Param ()

# start a stopwatch to time test run
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# load required modules and functions
Import-Module -Name Pester -RequiredVersion 4.9.0
Import-Module -Name Az.Resources
Import-Module -Name Az.ServiceBus
Import-Module $PSScriptRoot\..\..\output\PSServiceBus\PSServiceBus.psd1
Import-Module $PSScriptRoot\..\utils\PSServiceBus.Tests.Utils\bin\Release\netstandard2.0\PSServiceBus.Tests.Utils.dll
. $PSScriptRoot\..\utils\functions\IntegrationTestsFunctions.ps1

# prepare for test run
Write-Verbose -Message 'Preparing test run'

$testEnvironment = Initialize-IntegrationTestRun -Location 'uk south'

Write-Verbose -Message "Created environment $( $testEnvironment | ConvertTo-Json -Compress )"

$sbUtils = [PSServiceBus.Tests.Utils.ServiceBusUtils]::new($testEnvironment.ConnectionString)

Invoke-Pester -Script @{
    Path = $PSScriptRoot
    Parameters = @{
        ServiceBusUtils = $sbUtils
    }
}


# tear down environment
Write-Verbose -Message 'Removing test environment'

Complete-IntegrationTestRun -ResourceGroupName $testEnvironment.ResourceGroupName -Confirm:$false

# report on test run duration
$stopwatch.Stop()

Write-Verbose -Message "Integration test run completed in $( $stopwatch.Elapsed.ToString() )"