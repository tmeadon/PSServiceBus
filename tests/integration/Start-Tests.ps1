[CmdletBinding()]
Param ()

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

# run tests
foreach ($file in (Get-ChildItem -Path $PSScriptRoot -Filter '*.tests.ps1'))
{
    Invoke-Pester -Script @{
        Path = $file.FullName
        Parameters = @{
            ServiceBusUtils = $sbUtils
        }
    }
}

# tear down environment
Write-Verbose -Message 'Removing test environment'

Complete-IntegrationTestRun -ResourceGroupName $testEnvironment.ResourceGroupName -Confirm:$false
