param
(
    # Version number to stamp module manifest with
    [Parameter()]
    [version]
    $NewVersionNumber,

    # Version number to stamp module manifest with
    [Parameter()]
    [string]
    $PsGalleryKey
)

task . LintPowerShellFunctions, CleanModule, BuildModule, CopyFiles, CleanIntegrationTests, BuildIntegrationTests, RunIntegrationTests, UpdateVersion
task buildModuleOnly LintPowerShellFunctions, CleanModule, BuildModule, CopyFiles
task buildTestsOnly CleanIntegrationTests, BuildIntegrationTests

task SetVersionNumber {
    if ($NewVersionNumber)
    {
        $version = $NewVersionNumber
    }
    else
    {
        $version = (Get-Module "$BuildRoot\PSServiceBus.psd1" -ListAvailable).Version
    }
}

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
    $testResults = & "$BuildRoot\tests\integration\Start-Tests.ps1" -Verbose
    assert($testResults.FailedCount -eq 0) ("Failed $( $testResults.FailedCount ) integration tests.")
}

task UpdateVersion {
    try 
    {
        $manifestPath = "$BuildRoot\output\PSServiceBus.psd1"
        Update-ModuleManifest -Path $manifestPath -ModuleVersion $version
    }
    catch
    {
        Write-Error -Message $_.Exception.Message
        $host.SetShouldExit($LastExitCode)
    }
}
