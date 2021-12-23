param vmIndex int
param vmName string
param vmSize string
param osType string
param nsgId string
param subnetId string

param username string
@secure()
param password string

var osImages = {
    Linux: {
        publisher: 'Debian'
        offer: 'debian-11'
        sku: '11-gen2'
    }
    Windows: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-core-g2'
    }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
    name: vmName
    location: resourceGroup().location
    properties: {
        osProfile: {
            computerName: vmName
            adminUsername: username
            adminPassword: password
            customData: loadFileAsBase64('cloud-init.yaml')
            allowExtensionOperations: true
        }
        hardwareProfile: {
            vmSize: vmSize
        }
        storageProfile: {
            imageReference: {
                publisher: osImages[osType].publisher
                offer: osImages[osType].offer
                sku: osImages[osType].sku
                version: 'latest'
            }
            osDisk: {
                name: '${vmName}-disk'
                createOption: 'FromImage'
            }
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: vm_nic.id
                }
            ]
        }
    }
}

resource vm_pip 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
    name: '${vmName}-pip'
    location: resourceGroup().location
    properties: {
        publicIPAllocationMethod: 'Static'
    }
    sku: {
        name: 'Standard'
    }
}

resource vm_nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
    name: '${vmName}-nic'
    location: resourceGroup().location
    properties: {
        enableAcceleratedNetworking: true
        enableIPForwarding: false
        ipConfigurations: [
            {
                name: '${vmName}-ipconfig'
                properties: {
                    privateIPAddress: '10.0.0.${vmIndex + 4}'
                    privateIPAllocationMethod: 'Static'
                    publicIPAddress: {
                        id: vm_pip.id
                    }
                    subnet: {
                        id: subnetId
                    }
                }
            }
        ]
        networkSecurityGroup: {
            id: nsgId
        }
    }
}
