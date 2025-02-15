// version 1.0.0

@description('Name of the virtual network.')
param virtualNetworkName string

@description('Address range of the virtual network.')
param virtualNetworkAddressRange string

@description('An array of subnets with their names, address ranges, and optional NSG assignments.')
param subnets array

@description('Optional list of DNS server addresses. Leave empty to use Azure default.')
param DNSServerAddress array = []

@description('Deployment location.')
param location string

@description('Tags to be applied to the virtual network.')
param tags object = {}

param routeTableid string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: toLower(virtualNetworkName)
  tags: tags
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressRange
      ]
    }
    dhcpOptions: empty(DNSServerAddress) ? null : {
      dnsServers: DNSServerAddress
    }
    subnets: [
      for subnet in subnets: {
        name: toLower(subnet.name)
        properties: {
          addressPrefix: subnet.addressPrefix
          routeTable: !empty(subnet.routeTable) ? {
            id: routeTableid
          } : null
        }
      }
    ]
  }
}

@description('The list of subnet names created in the virtual network.')
output subnetNames array = [
  for subnet in subnets: subnet.name
]
