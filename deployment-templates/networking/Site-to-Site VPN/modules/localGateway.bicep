@description('Name of the Local Network Gateway.')
param localGatewayName string

@description('Location of the Local Network Gateway.')
param location string

@description('The IP address of the on-premises VPN device.')
param localGatewayIpAddress string

@description('The address prefixes of the on-premises network.')
param localAddressPrefixes array

resource localGateway 'Microsoft.Network/localNetworkGateways@2020-11-01' = {
  name: localGatewayName
  location: location
  properties: {
    gatewayIpAddress: localGatewayIpAddress
    localNetworkAddressSpace: {
      addressPrefixes: localAddressPrefixes
    }
  }
}

@description('The resource ID of the Local Network Gateway.')
output id string = localGateway.id
