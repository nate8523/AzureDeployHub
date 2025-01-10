// version 1.0.0

@description('The Azure region where the resources will be deployed.')
param location string

@description('Tags to apply to all resources in the deployment.')
param tags object

@description('')
param routeTableName string

@description('The address range for the virtual network.')
param virtualNetworkAddressRange string

param subnet2IP string
param subnet3Prefix string

resource routeTable 'Microsoft.Network/routeTables@2020-04-01' = {
  name: routeTableName
  tags: tags
  location: location
  properties: {
    routes: [
      {
        name: 'VirtualNetwork'
        properties: {
          addressPrefix: virtualNetworkAddressRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: subnet2IP
        }
      }
      {
        name: 'Subnet'
        properties: {
          addressPrefix: subnet3Prefix
          nextHopType: 'VnetLocal'
        }
      }
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: subnet2IP
        }
      }
    ]
  }
}

output routeTableid string = routeTable.id
