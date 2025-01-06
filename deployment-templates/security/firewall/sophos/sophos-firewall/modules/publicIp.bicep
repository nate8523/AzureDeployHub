@description('Name of the Public IP Address.')
param publicIpName string

@description('The location of the Public IP Address.')
param location string

@description('Tags to be applied to the Public IP Address.')
param tags object = {}

@description('The SKU for the Public IP Address.')
@allowed(['Basic', 'Standard'])
param publicIpsku string

@description('The allocation method for the Public IP Address.')
@allowed(['Static', 'Dynamic'])
param publicIPAllocationMethod string

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: toLower(publicIpName)
  tags: tags
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
