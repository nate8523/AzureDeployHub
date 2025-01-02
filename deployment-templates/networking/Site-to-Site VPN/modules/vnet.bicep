@description('Name of the virtual network.')
param virtualNetworkName string

@description('Address range of the virtual network (e.g., 10.0.0.0/16).')
param virtualNetworkAddressRange string

@description('An array of subnets with their names and address ranges.')
param subnets array

@description('Optional list of DNS server addresses.')
param DNSServerAddress array

@description('Deployment location.')
param location string

@description('The name of the Network Security Group.')
param nsgName string

var dhcpOptions = {
  dnsServers: DNSServerAddress
}

param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  tags: tags
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressRange
      ]
    }
    dhcpOptions: empty(DNSServerAddress) ? null : dhcpOptions
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          networkSecurityGroup: empty(subnet.networkSecurityGroup) || subnet.networkSecurityGroup != 'protected' ? null : {
            id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
          }
        }
      }
    ]
  }
}

@description('The resource ID of the GatewaySubnet.')
output gatewaySubnetId string = '${vnet.id}/subnets/GatewaySubnet'
