function Save-SbConnectionString
{
    [CmdletBinding()]
    Param
    (
        # Connection string to the Service Bus namespace
        [Parameter(Mandatory)]
        [string]
        $NamespaceConnectionString
    )

    try
    {
        # verify connection string
        if (Test-SbConnectionString -NamespaceConnectionString $NamespaceConnectionString)
        {
            $ModuleName = 'PSServiceBus'
            $Module = Get-Module -Name $ModuleName | Where-Object -FilterScript {$_.ModuleType -eq "Script"}
            $Commands = $Module.ExportedCommands.GetEnumerator()  | Select-Object -ExpandProperty value | Select-Object -ExpandProperty name

            foreach ($Command in $Commands)
            {
                $Global:PSDefaultParameterValues["$Command`:NamespaceConnectionString"] = $NamespaceConnectionString
            }
        }
        else
        {
            throw "Testing connection string was unsuccessful."
        }
    }
    catch
    {
        throw "Unable to save connection string.  Exception: $( $_.Exception.Message )"
    }
}
