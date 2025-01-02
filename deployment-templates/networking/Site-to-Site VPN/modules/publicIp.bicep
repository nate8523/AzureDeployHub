@description('Name of the Public IP Address.')
param publicIpName string

@description('The location of the Public IP Address.')
param location string

@description('The SKU for the Public IP Address. Defaults to "Standard".')
param publicIpsku string

@description('The allocation method for the Public IP Address. Options are "Static" or "Dynamic". Defaults to "Dynamic".')
param publicIPAllocationMethod string


resource publicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpsku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

@description('The resource ID of the Public IP Address.')
output publicIpId string = publicIp.id
