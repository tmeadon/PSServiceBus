param
(
    # Version number to stamp module manifest with
    [Parameter()]
    [version]
    $NewVersionNumber,

    # API key used to authenticate against the PowerShellGallery
    [Parameter()]
    [string]
    $PsGalleryKey,

    #SubcriptionId where you want the test to run against
    [Parameter()]
    [string]
    $TestLocation = "UK South",
    
    #SubcriptionId where you want the test to run against
    [Parameter()]
    [string]
    $TestSubscriptionId
)

task . LintPowerShellFunctions, CleanModule, BuildModule, CopyFiles, CleanIntegrationTests, BuildIntegrationTests, UpdateVersion
task buildAndTest LintPowerShellFunctions, CleanModule, BuildModule, CopyFiles, CleanIntegrationTests, BuildIntegrationTests, RunIntegrationTests, UpdateVersion
task runTestsBumpVersion RunIntegrationTests, UpdateVersion
task buildModuleOnly LintPowerShellFunctions, CleanModule, BuildModule, CopyFiles
task buildTestsOnly CleanIntegrationTests, BuildIntegrationTests

task LintPowerShellFunctions {
    $scriptAnalyzerParams = @{
        Path = "$BuildRoot\functions\"
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
    }

    $result = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    if ($result)
    {
        $result | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings were found."
    }
}

task CleanModule {
    if (Test-Path -Path "$BuildRoot\output" -PathType Container)
    {
        Remove-Item -Path "$BuildRoot\output" -Recurse
    }
    dotnet.exe clean "$BuildRoot\src\PSServiceBus.sln" -c release
}

task BuildModule {
    dotnet.exe build "$BuildRoot\src\PSServiceBus.sln" -c release
}

task CopyFiles {
    New-Item -ItemType Directory -Path "$BuildRoot\output\PSServiceBus"
    Copy-Item -Path "$BuildRoot\PSServiceBus.ps*" -Destination "$BuildRoot\output\PSServiceBus"
    Copy-Item -Path "$BuildRoot\src\PSServiceBus\bin\Release\netstandard2.0" -Destination "$BuildRoot\output\PSServiceBus\bin" -Recurse
    Copy-Item -Path "$BuildRoot\functions" -Destination "$BuildRoot\output\PSServiceBus\functions" -Recurse
}

task CleanIntegrationTests {
    dotnet.exe clean "$BuildRoot\tests\utils\PSServiceBus.Tests.Utils.sln" -c release
}

task BuildIntegrationTests {
    dotnet.exe build "$BuildRoot\tests\utils\PSServiceBus.Tests.Utils.sln" -c release
}

task RunIntegrationTests {
    $testResults = & "$BuildRoot\tests\integration\Start-Tests.ps1" -SubscriptionId $TestSubscriptionId -Location $TestLocation -Verbose
    assert($testResults.FailedCount -eq 0) ("Failed $( $testResults.FailedCount ) integration tests.")
}

task UpdateVersion {
    if ($NewVersionNumber)
    {
        # set the version in manifest
        Update-ModuleManifest -Path "$BuildRoot\output\PSServiceBus\PSServiceBus.psd1" -ModuleVersion $NewVersionNumber

        # overwrite the source manifest with the updated one
        Copy-Item -Path "$BuildRoot\output\PSServiceBus\PSServiceBus.psd1" -Destination $BuildRoot -Force
    }
}

task PublishToGallery {
    if (-not $PsGalleryKey)
    {
        throw "You must supply a value for the the -PSGalleryKey in order to run this task"
    }
    Import-Module "$BuildRoot\output\PSServiceBus\PSServiceBus.psd1" -Force
    Publish-Module -Name "PSServiceBus" -NuGetApiKey $PsGalleryKey -Repository 'PSGallery'
}
