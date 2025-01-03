@description('The name of the Network Interface.')
param networkInterfaceName string

@description('The location of the Network Interface.')
param location string

@description('Tags to be applied to the virtual network.')
param tags object = {}

@description('The name of the Public IP Address associated with the Network Interface.')
param publicIpName string

@description('The name of the Network Security Group to associate with the Network Interface.')
param nsgName string

@description('The name of the Virtual Network.')
param virtualNetworkName string

@description('The name of the Subnet within the Virtual Network.')
param subnetName string

@description('The delete option for the Public IP Address.')
@allowed(['Delete', 'Detach'])
param publicIpDeleteOption string = 'Delete'

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: networkInterfaceName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIpAddresses', publicIpName)
            properties: {
              deleteOption: publicIpDeleteOption
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
    }
  }
}
