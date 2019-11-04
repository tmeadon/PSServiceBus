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

task CleanTests {
    dotnet.exe clean "$BuildRoot\tests\utils\PSServiceBus.Tests.Utils.sln" -c release
}

task BuildTests {
    dotnet.exe build "$BuildRoot\tests\utils\PSServiceBus.Tests.Utils.sln" -c release
}

task RunTests {
    & "$BuildRoot\tests\integration\Start-Tests.ps1" -Verbose
}

task . CleanModule, BuildModule, CopyFiles, CleanTests, BuildTests, RunTests
task buildmoduleonly CleanModule, BuildModule, CopyFiles
task buildtestsonly CleanTests, BuildTests
task runtestsonly RunTests

