function Initialize-IntegrationTestRun
{
    #Requires -Module Az.Resources
    #Requires -Module Az.ServiceBus
    
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        # Azure region to use for tests
        [Parameter(Mandatory)]
        [string]
        $Location
    )

    # test that az module is logged in
    Get-AzSubscription -ErrorAction Stop | Out-Null

    # store current subscription
    $subscription = (Get-AzContext).Subscription.Name

    # test that supplied location is valid
    $validLocations = Get-AzLocation

    if (($Location -notin $validLocations.DisplayName) -and ($Location -notin $validLocations.Location))
    {
        throw "Location is not valid.  Run 'Get-AzLocation' for a list of valid locations."
    }

    # create a guid for resource naming which must start with a letter to satisfy service bus namespace naming constraint
    $guid = ""
    while ($guid[0] -notmatch "[a-zA-Z]")
    {
        $guid = (New-Guid).Guid
    }

    if ($PSCmdlet.ShouldProcess($subscription, "Creating new resource group and service bus namespace with name $guid"))
    {
        # create a new resource group for testing
        $resourceGroup = New-AzResourceGroup -Name $guid -Location $Location -ErrorAction Stop

        # create a new service bus namespace for testing
        $namespace = New-AzServiceBusNamespace -ResourceGroupName $resourceGroup.ResourceGroupName -Location $Location -Name $guid -ErrorAction Stop -WarningAction SilentlyContinue

        # get the connection string for the new namespace
        $authRule = Get-AzServiceBusAuthorizationRule -ResourceGroupName $resourceGroup.ResourceGroupName -Namespace $namespace.Name | Where-Object {$_.Rights -contains 'Manage'}
        $connectionString = (Get-AzServiceBusKey -ResourceGroupName $resourceGroup.ResourceGroupName -Namespace $namespace.Name -Name ($authRule[0]).Name).PrimaryConnectionString

        # return namespace details
        return [PSCustomObject]@{
            Subscription = $subscription
            ResourceGroupName = $resourceGroup.ResourceGroupName
            ServiceBusNamespace = $namespace.Name
            ConnectionString = $connectionString
        }
    }
}

function Complete-IntegrationTestRun
{
    #Requires -Module Az.Resources 

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param
    (
        # Name of the resource group containing test resources
        [Parameter(Mandatory)]
        [string]
        $ResourceGroupName
    )

    $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

    if ($PSCmdlet.ShouldProcess($resourceGroup.ResourceGroupName))
    {
        Remove-AzResourceGroup -Name $resourceGroup.ResourceGroupName -Force | Out-Null
    }
}
