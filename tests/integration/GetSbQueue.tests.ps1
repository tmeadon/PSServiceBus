[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Get-SbQueue tests" {

    Context "Parameter tests" {

        # setup 

        $newQueues = $ServiceBusUtils.CreateQueues(4)
        Start-Sleep -Seconds 5
        $allQueues = $ServiceBusUtils.GetAllQueues();

        # tests

        It "should return all of the queues if -QueueName parameter is not specified" {  
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString
            $result.count | Should -EQ $allQueues.count
        }

        $testCases = @(
            @{
                queueName = $newQueues[0]
            }
            @{
                queueName = $newQueues[1]
            }
        )

        It "should return the correct queue if -QueueName parameter is specifed" -TestCases $testCases {
            param ([string] $queueName)
            $result = Get-SbQueue -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString -QueueName $queueName
            $result.Name | Should -Be $queueName
        }

        # teardown

        foreach ($item in $newQueues)
        {
            $ServiceBusUtils.RemoveQueue($item)
        }
    }
}

# SIG # Begin signature block
# MIIIpQYJKoZIhvcNAQcCoIIIljCCCJICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUK2EEbwvkQWHm6IRqjY7+kf4j
# NbKgggYIMIIGBDCCBOygAwIBAgIKLYzbQgAAAAFDIjANBgkqhkiG9w0BAQUFADBY
# MRIwEAYKCZImiZPyLGQBGRYCdWsxEjAQBgoJkiaJk/IsZAEZFgJjbzEYMBYGCgmS
# JomT8ixkARkWCGR2Y3NhbGVzMRQwEgYDVQQDEwtTS1lDQTAwMS1DQTAeFw0xOTAz
# MjIxNTE5MTZaFw0yMDAzMjExNTE5MTZaMIGUMRIwEAYKCZImiZPyLGQBGRYCdWsx
# EjAQBgoJkiaJk/IsZAEZFgJjbzEYMBYGCgmSJomT8ixkARkWCGR2Y3NhbGVzMQww
# CgYDVQQLEwNNSVMxEjAQBgNVBAsTCU1JUyBVc2VyczEXMBUGA1UECxMOQWRtaW4g
# QWNjb3VudHMxFTATBgNVBAMTDEFkbWluIE1lYWRvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAM1TQ5dkVpFSfzNlBf9554d/v1/5sei7jrUGWgAj78dN
# 8IxkpjnzcFL0ZYCjHvb9/ZkpqInUxHGxro7VDSKMpaX0QsrVQpXRHAbtghfhdsPf
# fsx7WxS1YUKHTjUE6XceeyLU8nBSXGVKN5NjKIlrwZ1Z3aZIzQJET/cqw0HH0cmb
# 8repl9xXQ0fYuP+0mjaO2WNB8yOK5lMp2GEYdhEdnpNEsRMn4CSrxMlo6SknYw0f
# lOWBh3SUKYOcFxex1+CjtCfb5BGVAJf04nSE8+9X16ckws9OIkleRZafc9P07W7e
# 6knCjAtNikDIesRcC53+1YX4OEbV4F7RJptNNvy6Wr0CAwEAAaOCApEwggKNMDsG
# CSsGAQQBgjcVBwQuMCwGJCsGAQQBgjcVCIT6ZqiQIoXpkQSC9JNzh7+/eGSDluI3
# hcvaXAIBZAIBBDATBgNVHSUEDDAKBggrBgEFBQcDAzALBgNVHQ8EBAMCB4AwGwYJ
# KwYBBAGCNxUKBA4wDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUrgsOxoi5z0w7eHSB
# 21xflPh46XYwHwYDVR0jBBgwFoAU8JZLzbtIU/IOxon/gAwg9EEDrDwwgdAGA1Ud
# HwSByDCBxTCBwqCBv6CBvIaBuWxkYXA6Ly8vQ049U0tZQ0EwMDEtQ0EsQ049c2t5
# Y2EwMDEsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZp
# Y2VzLENOPUNvbmZpZ3VyYXRpb24sREM9ZHZjc2FsZXMsREM9Y28sREM9dWs/Y2Vy
# dGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3Ry
# aWJ1dGlvblBvaW50MIHDBggrBgEFBQcBAQSBtjCBszCBsAYIKwYBBQUHMAKGgaNs
# ZGFwOi8vL0NOPVNLWUNBMDAxLUNBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBT
# ZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWR2Y3NhbGVz
# LERDPWNvLERDPXVrP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0
# aWZpY2F0aW9uQXV0aG9yaXR5MDYGA1UdEQQvMC2gKwYKKwYBBAGCNxQCA6AdDBtB
# ZG1pbi5NZWFkb25AZHZjc2FsZXMuY28udWswDQYJKoZIhvcNAQEFBQADggEBAJd6
# 23IF+EAlWI9FYGThX3jLqPzXmIgd12c5MFvOEZ/M4IzT4T+ewrmsQvPPXbrH9kEz
# e6kOHINkIlyaR3BuEuXnUN3A6vN2RyfM3VNTFDNUBwjjvEfYQa+XvVi99wpJkUlM
# 8wja1Zi3qoUnpE4846xOVshtsh/l3FF5q5rtLN4E6ysmMht8pl/qRWPgtwOgIgXs
# h4XLBFs2ORCy/VRwm1gostQu3jUN2RXV3dhT5kC2OyMmnLc8mtoIxkH1qGyg2dnj
# 0Pcr+u+IbYaSAfQOCQ6xBgnQL44JYZTnGIy6jq2+5ZgOyHULMR9uEm7jMPZOrir+
# 4pllJOABWjbSG+Ka8doxggIHMIICAwIBATBmMFgxEjAQBgoJkiaJk/IsZAEZFgJ1
# azESMBAGCgmSJomT8ixkARkWAmNvMRgwFgYKCZImiZPyLGQBGRYIZHZjc2FsZXMx
# FDASBgNVBAMTC1NLWUNBMDAxLUNBAgotjNtCAAAAAUMiMAkGBSsOAwIaBQCgeDAY
# BgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEW
# BBRti+csg8l/PW4Ee8pNw9tClGQr3TANBgkqhkiG9w0BAQEFAASCAQBe1KCG2KGV
# 9XxX6GuTG02HQHICu18ZFg23zgeA0P6AJMVAVAmhIraJNZK789uS9sbJT4RjUv5x
# UbfZKkV53FKdKq/5k+dK1FUCOwExBfN0xKPAKGxscF8yJrzxYinkhmtoVBJ5Ja7H
# ZE+UWeE6x1720+uPZRrjzGd97Q4no/7A1XoUAZuGTa/79SW0j79E/012tVLD+Mpd
# pyuGPfYNImaL6Yu/h4HhmiU7Y3hUrkGLYaTzeJqh2Nstk7IQg502h6i0azWxJf5q
# UUja1i9MdLyjw5oRCUr7yoHmssqagS0LFeuS2RpMWZ+Lw57rO6XDbf8SQ/FJMw3d
# qb5nloylHJTX
# SIG # End signature block
