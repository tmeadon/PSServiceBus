task CleanModule {
    if (Test-Path -Path .\output -PathType Container)
    {
        Remove-Item -Path '.\output' -Recurse
    }
    dotnet.exe clean .\src\PSServiceBus.sln -c release
}

task BuildModule {
    dotnet.exe build .\src\PSServiceBus.sln -c release
}

task CopyFiles {
    New-Item -ItemType Directory -Path '.\output\PSServiceBus'
    Copy-Item -Path '.\PSServiceBus.ps*' -Destination '.\output\PSServiceBus'
    Copy-Item -Path '.\src\PSServiceBus\bin\Release\netstandard2.0' -Destination '.\output\PSServiceBus\bin' -Recurse
    Copy-Item -Path '.\functions' -Destination '.\output\PSServiceBus\functions' -Recurse
}

task CleanTests {
    dotnet.exe clean .\tests\utils\PSServiceBus.Tests.Utils.sln -c release
}

task BuildTests {
    dotnet.exe build .\tests\utils\PSServiceBus.Tests.Utils.sln -c release
}

task RunTests {
    .\tests\integration\Start-Tests.ps1 -Verbose
}

task . CleanModule, BuildModule, CopyFiles, CleanTests, BuildTests, RunTests
task testsonly CleanTests, BuildTests
