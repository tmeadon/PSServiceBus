# PSServiceBus

A PowerShell module for interacting with Azure Service Bus.

[![Build Status](https://dev.azure.com/tommagumma1/PSServiceBus/_apis/build/status/tommagumma.PSServiceBus?branchName=master)](https://dev.azure.com/tommagumma1/PSServiceBus/_build/latest?definitionId=1&branchName=master)

## Overview

This PowerShell modules enables interaction with Azure Service Bus queues, topics and subscriptions.  It can be used to not only report on the current status of the various Service Bus entities, but also to send and receive messages from those entities.

## Installation

The module is hosted on the PowerShell Gallery meaning it can be installed by running:

`Install-Module -Name PSServiceBus`

## Available Commands

| Command                 | Description                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------- |
| Get-SbQueue             | Returns message count details for all queues or a specific queue                          |
| Get-SbTopic             | Returns a list of subscriptions for all topics or a specific topic                        |
| Get-SbSubscription      | Returns message count details for all subscriptions or a specific subscription in a topic |
| Receive-SbMessage       | Retrieves a message or multiple messages from a queue or subscription                     |
| Send-SbMessage          | Sends a message to a queue or a topic                                                     |
| Save-SbConnectionString | Stores a connection string for use with future commands                                   |
| Test-SbConnectionString | Tests the validity of a connection string                                                 |

## Usage

To get started with PSServiceBus, first retrieve a connection string (with the 'Manage' claim) from your Service Bus namespace either from the Azure Portal or by using the following Az commands:

```powershell
$authRule = Get-AzServiceBusAuthorizationRule -ResourceGroupName {ResourceGroupName} -Namespace {NamespaceName} | Where-Object {$_.Rights -contains 'Manage'} | Select-Object -First 1

$connectionString = (Get-AzServiceBusKey -ResourceGroupName {ResourceGroupName} -Namespace {NamespaceName} -Name $authRule.Name).PrimaryConnectionString
```

Next, save the connection string in your current PowerShell session to prevent having to pass it into each future command execution:

`Save-SbConnectionString -NamespaceConnectionString $connectionString`

Now you are good to go!

`Get-SbQueue -QueueName 'my-queue'`

## Folder structure

- `/` - home for main module files and build files
- `src/` - this is where the C# solution lives that contains the binary cmdlets
- `tests/integration/` - files containing Pester integration tests and a script to run them
- `tests/utils/` - some helpers for the integration tests including some PowerShell functions and another C# solution
- `functions/public` - additional PowerShell functions that will be available to the user

## Build

There is an [Invoke Build](https://github.com/nightroman/Invoke-Build) script at the root of this repository which will carry out the required steps to build and test the module.  All being well it will drop the built module in a folder called 'output'.  There are a few options for running the build:

- `Invoke-Build` - this will lint the PowerShell functions, clean and build the binary cmdlets, clean and build the integration test helper binaries
- `Invoke-Build buildAndTest` - this will do all of the above but will also execute the integration tests
- `Invoke-Build runTestsBumpVersion` - this will only run the integration tests and bump the version number
- `Invoke-Build buildModuleOnly` - this will do the linting and building of the module only
- `Invoke-Build buildTestsOnly` - this will build the integration test helper binaries only

The script has some additional optional parameters:

- `-NewVersionNumber` - this will stamp the module manifest in the output directory with the version number supplied (must be semver)
- `-PsGalleryKey` - this will enable the module to be published to the PSGallery - *not implemented yet*

### Build Requirements

To execute the build script you need the following (note this doesn't include the requirements for running the tests, only for building the module):

- PowerShell modules:
  - PSScriptAnalyzer
  - InvokeBuild
- [.Net Core CLI tools](https://docs.microsoft.com/en-us/dotnet/core/tools/?tabs=netcore2x)

## Tests

In its current state the code in this module is essentially just a wrapper around some of the Microsoft.Azure.ServiceBus classes, as such there is no requiremnent for unit tests because they would be primarily testing someone else's code.  Instead integration tests have been written to ensure that the module interacts with Azure Service Bus as expected.  To run the full suite of integration tests simply run:

`tests\integration\Start-Tests.ps1`

The script will first provision a temporary environment in Azure (see requirements below) and will then execute all of the tests.  After it is done the environment will be destroyed.

### Tests Requirements

In order to run the tests you will need the following:

- An Azure subscription and an account with the privileges to:
  - Create and delete resource groups
  - Create and delete Service Bus resources
- PowerShell modules:
  - Pester (version >= 4.9.0)
  - Az.Resources
  - Az.ServiceBus
