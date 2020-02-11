[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Test-SbMessageBatchSize tests" {

    # create a large string to test size limits
    $largeMessage = ""

    while ($largeMessage.Length -lt 50000)
    {
        $largeMessage += (Get-Random).ToString()
    }

    # create a small string for testing message count limits
    $smallMessage = (Get-Random).ToString()

    # use the strings to create some batches
    $batch_Lt100Msgs_Lt256Kb_Lt1Mb = @(1..20 | ForEach-Object -Process {$smallMessage})
    $batch_Lt100Msgs_Gt256Kb_Lt1Mb = @(1..10 | ForEach-Object -Process {$largeMessage})
    $batch_Lt100Msgs_Gt256Kb_Gt1Mb = @(1..30 | ForEach-Object -Process {$largeMessage})
    $batch_Gt100Msgs_Lt256Kb_Lt1Mb = @(1..110 | ForEach-Object -Process {$smallMessage})

    # store details of the sku in use for tests
    $currentSku = $ServiceBusUtils.GetNamespaceSku()

    switch ($currentSku)
    {
        "Basic"     {$maxMessageSize = 256000}
        "Standard"  {$maxMessageSize = 256000}
        "Premium"   {$maxMessageSize = 1000000}
        Default     {throw "Unable to get the max message size for $currentSku"}
    }

    # create some test cases for the various Service Bus skus
    $basicSkuTests = @(
        @{
            batch = $batch_Lt100Msgs_Lt256Kb_Lt1Mb
            expectedResult = $true
            expectedReason = "BatchWithinLimits"
        },
        @{
            batch = $batch_Lt100Msgs_Gt256Kb_Lt1Mb
            expectedResult = $false
            expectedReason = "BatchTooLarge"
        },
        @{
            batch = $batch_Lt100Msgs_Gt256Kb_Gt1Mb
            expectedResult = $false
            expectedReason = "BatchTooLarge"
        },
        @{
            batch = $batch_Gt100Msgs_Lt256Kb_Lt1Mb
            expectedResult = $false
            expectedReason = "TooManyItems"
        }
    )

    $standardSkuTests = @(
        @{
            batch = $batch_Lt100Msgs_Lt256Kb_Lt1Mb
            expectedResult = $true
            expectedReason = "BatchWithinLimits"
        },
        @{
            batch = $batch_Lt100Msgs_Gt256Kb_Lt1Mb
            expectedResult = $false
            expectedReason = "BatchTooLarge"
        },
        @{
            batch = $batch_Lt100Msgs_Gt256Kb_Gt1Mb
            expectedResult = $false
            expectedReason = "BatchTooLarge"
        },
        @{
            batch = $batch_Gt100Msgs_Lt256Kb_Lt1Mb
            expectedResult = $false
            expectedReason = "TooManyItems"
        }
    )

    $premiumSkuTests = @(
        @{
            batch = $batch_Lt100Msgs_Lt256Kb_Lt1Mb
            expectedResult = $true
            expectedReason = "BatchWithinLimits"
        },
        @{
            batch = $batch_Lt100Msgs_Gt256Kb_Lt1Mb
            expectedResult = $true
            expectedReason = "BatchWithinLimits"
        },
        @{
            batch = $batch_Lt100Msgs_Gt256Kb_Gt1Mb
            expectedResult = $false
            expectedReason = "BatchTooLarge"
        },
        @{
            batch = $batch_Gt100Msgs_Lt256Kb_Lt1Mb
            expectedResult = $false
            expectedReason = "TooManyItems"
        }
    )

    Context "Test parameter attributes" {

        It "Messages parameter should be mandatory" {
            (Get-Command -Name Test-SbMessageBatchSize).Parameters['Messages'].Attributes.Mandatory | Should -Be $true
        }

    }

    Context "Test without -NamespaceConnectionString parameter" {

        It "should return the correct batch size" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb).BatchSize | Should -Be ("{0}B" -f ($ServiceBusUtils.GetMessageBatchSize($batch_Lt100Msgs_Lt256Kb_Lt1Mb)))
        }

        It "should return the correct number of messages" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb).NumberOfMessages | Should -Be $batch_Lt100Msgs_Lt256Kb_Lt1Mb.Count
        }

        It "should return the correct result value for 'ValidForBasicSku'" -TestCases $basicSkuTests {
            param ([string[]] $batch, [bool] $expectedResult)
            (Test-SbMessageBatchSize -Messages $batch).ValidForBasicSku.Result | Should -Be $expectedResult
        }

        It "should return the correct reason value for 'ValidForBasicSku'" -TestCases $basicSkuTests {
            param ([string[]] $batch, [string] $expectedReason)
            (Test-SbMessageBatchSize -Messages $batch).ValidForBasicSku.Reason | Should -Be $expectedReason
        }

        It "should return the correct result value for 'ValidForStandardSku'" -TestCases $standardSkuTests {
            param ([string[]] $batch, [bool] $expectedResult)
            (Test-SbMessageBatchSize -Messages $batch).ValidForStandardSku.Result | Should -Be $expectedResult
        }

        It "should return the correct reason value for 'ValidForStandardSku'" -TestCases $standardSkuTests {
            param ([string[]] $batch, [string] $expectedReason)
            (Test-SbMessageBatchSize -Messages $batch).ValidForStandardSku.Reason | Should -Be $expectedReason
        }

        It "should return the correct result value for 'ValidForPremiumSku'" -TestCases $premiumSkuTests {
            param ([string[]] $batch, [bool] $expectedResult)
            (Test-SbMessageBatchSize -Messages $batch).ValidForPremiumSku.Result | Should -Be $expectedResult
        }

        It "should return the correct reason value for 'ValidForPremiumSku'" -TestCases $premiumSkuTests {
            param ([string[]] $batch, [string] $expectedReason)
            (Test-SbMessageBatchSize -Messages $batch).ValidForPremiumSku.Reason | Should -Be $expectedReason
        }

        It "should return null for 'CurrentNamespaceSku'" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb).CurrentNamespaceSku | Should -Be $null
        }

        It "should return null for 'ValidForCurrentNamespace'" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb).ValidForCurrentNamespace | Should -Be $null
        }
    }

    Context "Tests with -NamespaceConnectionString parameter" {

        It "should return the correct batch size" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).BatchSize | Should -Be ("{0}B" -f ($ServiceBusUtils.GetMessageBatchSize($batch_Lt100Msgs_Lt256Kb_Lt1Mb)))
        }

        It "should return the correct number of messages" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).NumberOfMessages | Should -Be $batch_Lt100Msgs_Lt256Kb_Lt1Mb.Count
        }

        It "should return the correct result value for 'ValidForBasicSku'" -TestCases $basicSkuTests {
            param ([string[]] $batch, [bool] $expectedResult)
            (Test-SbMessageBatchSize -Messages $batch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).ValidForBasicSku.Result | Should -Be $expectedResult
        }

        It "should return the correct reason value for 'ValidForBasicSku'" -TestCases $basicSkuTests {
            param ([string[]] $batch, [string] $expectedReason)
            (Test-SbMessageBatchSize -Messages $batch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).ValidForBasicSku.Reason | Should -Be $expectedReason
        }

        It "should return the correct result value for 'ValidForStandardSku'" -TestCases $standardSkuTests {
            param ([string[]] $batch, [bool] $expectedResult)
            (Test-SbMessageBatchSize -Messages $batch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).ValidForStandardSku.Result | Should -Be $expectedResult
        }

        It "should return the correct reason value for 'ValidForStandardSku'" -TestCases $standardSkuTests {
            param ([string[]] $batch, [string] $expectedReason)
            (Test-SbMessageBatchSize -Messages $batch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).ValidForStandardSku.Reason | Should -Be $expectedReason
        }

        It "should return the correct result value for 'ValidForPremiumSku'" -TestCases $premiumSkuTests {
            param ([string[]] $batch, [bool] $expectedResult)
            (Test-SbMessageBatchSize -Messages $batch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).ValidForPremiumSku.Result | Should -Be $expectedResult
        }

        It "should return the correct reason value for 'ValidForPremiumSku'" -TestCases $premiumSkuTests {
            param ([string[]] $batch, [string] $expectedReason)
            (Test-SbMessageBatchSize -Messages $batch -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).ValidForPremiumSku.Reason | Should -Be $expectedReason
        }

        It "should return the correct value for 'CurrentNamespaceSku'" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).CurrentNamespaceSku | Should -Be $ServiceBusUtils.GetNamespaceSku()
        }

        It "should return the correct result value for 'ValidForCurrentNamespace'" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).ValidForCurrentNamespace.Result | Should -Be $true
        }

        It "should return the correct reason value for 'ValidForCurrentNamespace'" {
            (Test-SbMessageBatchSize -Messages $batch_Lt100Msgs_Lt256Kb_Lt1Mb -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString).ValidForCurrentNamespace.Reason | Should -Be "BatchWithinLimits"
        }
    }
}