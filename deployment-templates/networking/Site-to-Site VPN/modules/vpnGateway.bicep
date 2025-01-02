@description('Name of the VPN Gateway.')
param vpnGatewayName string

@description('Location of the VPN Gateway.')
param location string

@description('The ID of the Public IP Address to associate with the VPN Gateway.')
param publicIpId string

@description('The Virtual Network Gateway SKU.')
param gatewaySku string

@description('The Gateway Type.')
param gatewayType string

@description('The VPN Type.')
param vpnType string

@description('The Subnet ID for the GatewaySubnet in the Virtual Network.')
param gatewaySubnetId string

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: vpnGatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpId
          }
          subnet: {
            id: gatewaySubnetId
          }
        }
      }
    ]
    gatewayType: gatewayType
    vpnType: vpnType
    sku: {
      name: gatewaySku
    }
    enableBgp: false
  }
}

@description('The resource ID of the VPN Gateway.')
output id string = vpnGateway.id
