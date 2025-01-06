// version 1.0.0

@description('Location for the resources.')
param location string

@description('Tags to apply to the resources.')
param tags object

@description('An array of network interfaces to be deployed.')
param networkInterfaces array

@description('The name of the virtual network.')
param virtualNetworkName string

@description('Deployment prefix for naming resources.')
param deploymentPrefix string

@description('Deployment type (e.g., dev, prod).')
param deploymentType string

@description('Short identifier for the location.')
param locationShort string

param publicIpId string

resource networkInterfaceArray 'Microsoft.Network/networkInterfaces@2021-05-01' = [for (nic, i) in networkInterfaces: {
  name: toLower('${deploymentPrefix}-nic-${deploymentType}-${locationShort}-${nic.networkInterfaceName}')
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, nic.subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: toLower('${deploymentPrefix}-nic-${deploymentType}-${locationShort}-${nic.networkInterfaceName}') == toLower('${deploymentPrefix}-nic-${deploymentType}-${locationShort}-port-b') ? {
            id: publicIpId
          } : null
        }
      }
    ]
  }
}]
