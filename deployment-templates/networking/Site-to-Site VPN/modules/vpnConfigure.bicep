@description('Location of the VPN Gateway.')
param location string

@description('The resource ID of the VPN Gateway.')
param vpnGatewayId string

@description('Name of the VPN Gateway.')
param vpnGatewayName string

@description('Name of the VPN Connection.')
param connectionName string

@description('The resource ID of the Local Network Gateway.')
param localGatewayId string

@description('Auto-generated Pre-Shared Key.')
var sharedKey = '${uniqueString(subscription().id, resourceGroup().name, vpnGatewayName)}${uniqueString(subscription().id, connectionName)}'


@description('Enable or disable BGP for the connection.')
param enableBgp bool

resource vpnConnection 'Microsoft.Network/connections@2020-11-01' = {
  name: connectionName
  location: location
  properties: {
    connectionType: 'IPsec'
    virtualNetworkGateway1: {
      properties: {
      }
      id: vpnGatewayId
    }
    localNetworkGateway2: {
      properties: {
      }
      id: localGatewayId
    }
    sharedKey: sharedKey
    enableBgp: enableBgp
  }
}

@description('The resource ID of the VPN connection.')
output vpnConnectionId string = vpnConnection.id
