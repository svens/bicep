targetScope = 'subscription'

param location string = 'northeurope'

param login_ip string
param username string
@secure()
param password string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: '${username}-udp'
    location: location
}

module net './net.bicep' = {
    name: 'net'
    scope: rg
    params: {
        login_ip: login_ip
    }
}

var relays = [
    {
        vmName: 'udp-relay-linux'
        vmSize: 'Standard_F4s_v2'
        osType: 'Linux'
    }
    {
        vmName: 'udp-relay-win'
        vmSize: 'Standard_F4s_v2'
        osType: 'Windows'
    }
]

module relay_vm './vm.bicep' = [for (relay, index) in relays: {
    name: relay.vmName
    scope: rg
    params: {
        vmIndex: index
        vmName: relay.vmName
        vmSize: relay.vmSize
        osType: relay.osType
        nsgId: net.outputs.nsgId
        subnetId: net.outputs.subnetId
        username: username
        password: password
    }
}]

module client_vm './vm.bicep' = [for index in range(1, 6): {
    name: 'udp-client-${index}'
    scope: rg
    params: {
        vmIndex: index + length(relays)
        vmName: 'udp-client-${index}'
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        nsgId: net.outputs.nsgId
        subnetId: net.outputs.subnetId
        username: username
        password: password
    }
}]
