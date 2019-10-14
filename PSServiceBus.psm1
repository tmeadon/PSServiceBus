# Dot source all public and private functions
Get-ChildItem -Path $PSScriptRoot\functions -Filter "*.ps1" -Recurse | ForEach-Object {
    
    . $_.FullName
    
}
