# PSServiceBus

A PowerShell module for interacting with Azure Service Bus.

[![Build Status](https://dev.azure.com/tommagumma/PSServiceBus/_apis/build/status/tommagumma.PSServiceBus?branchName=master)](https://dev.azure.com/tommagumma/PSServiceBus/_build/latest?definitionId=1&branchName=master)

## Overview 

This PowerShell modules enables interaction with Azure Service Bus queues, topics and subscriptions.  It can be used to not only report on the current status of the various Service Bus entities, but also to send and receive messages from those entities.

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

```
$authRule = Get-AzServiceBusAuthorizationRule -ResourceGroupName {ResourceGroupName} -Namespace {NamespaceName} | Where-Object {$_.Rights -contains 'Manage'} | Select-Object -First 1

$connectionString = (Get-AzServiceBusKey -ResourceGroupName {ResourceGroupName} -Namespace {NamespaceName} -Name $authRule.Name).PrimaryConnectionString
```

Next, save the connection string in your current PowerShell session to prevent having to pass it into each future command execution:

`Save-SbConnectionString -NamespaceConnectionString $connectionString`

Now you are good to go!

`Get-SbQueue -QueueName 'my-queue'`

## Folder structure



## Build

This module is built using the module 'InvokeBuild' by simply changing location to the module root and running `Invoke-Build`.  The default task will lint any PowerShell functions, clean and build the binary cmdlets then clean and build the integration test util binaries.

### Requirements

## Tests

### Requirements

