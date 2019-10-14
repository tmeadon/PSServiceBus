task Clean {
    Remove-Item -Path '.\output' -Recurse
    dotnet.exe clean .\src\PSServiceBus.sln -c release
}

task Build {
    dotnet.exe build .\src\PSServiceBus.sln -c release
}

task CopyFiles {
    New-Item -ItemType Directory -Path '.\output\PSServiceBus'
    Copy-Item -Path '.\PSServiceBus.ps*' -Destination '.\output\PSServiceBus'
    Copy-Item -Path '.\src\PSServiceBus\bin\Release\netstandard2.0' -Destination '.\output\PSServiceBus\bin' -Recurse
    Copy-Item -Path '.\functions' -Destination '.\output\PSServiceBus\functions' -Recurse
}

task . Clean, Build, CopyFiles
