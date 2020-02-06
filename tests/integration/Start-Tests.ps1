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

# Don't care about what subscription you will be working against?
$testEnvironment = Initialize-IntegrationTestRun -Location 'uk south'

# Have dedicated subscription you want to use?
#$testEnvironment = Initialize-IntegrationTestRun -Location 'uk south' -SubscriptionId "7c569866-2b86-43ac-ad3c-1b132add158d"

Write-Verbose -Message "Created environment $( $testEnvironment | ConvertTo-Json -Compress )"

$sbUtils = [PSServiceBus.Tests.Utils.ServiceBusUtils]::new($testEnvironment.ConnectionString)

$testResults = Invoke-Pester -Strict -PassThru -EnableExit -Script @{
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

# return the test results to the pipeline
Write-Output -InputObject $testResults