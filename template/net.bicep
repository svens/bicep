param login_ip string

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
    name: 'nsg'
    location: resourceGroup().location
    properties: {
        securityRules: [
            {
                name: 'allow-login'
                properties: {
                    priority: 1001
                    access: 'Allow'
                    direction: 'Inbound'
                    protocol: 'Tcp'
                    destinationAddressPrefix: '*'
                    destinationPortRanges: [
                        '22'
                        '3389'
                    ]
                    sourceAddressPrefixes: [
                        login_ip
                    ]
                    sourcePortRange: '*'
                }
            }
        ]
    }
}
output nsgId string = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', 'nsg')

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
    name: 'vnet'
    location: resourceGroup().location
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.0.0.0/16'
            ]
        }
        subnets: [
            {
                name: 'vnet-subnet'
                properties: {
                    addressPrefix: '10.0.0.0/24'
                    networkSecurityGroup: {
                        id: nsg.id
                    }
                }
            }
        ]
    }
}
var _vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', 'vnet')
output vnetId string = _vnetId
output subnetId string = '${_vnetId}/subnets/vnet-subnet'
