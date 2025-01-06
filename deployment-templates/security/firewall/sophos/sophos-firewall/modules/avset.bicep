@description('The Azure region where the Availability Set will be deployed.')
param location string

@description('Tags to apply to the Availability Set.')
param tags object

@description('The name of the Availability Set.')
param availabilitySetName string

@description('The number of fault domains.')
param faultDomains int

@description('The number of update domains.')
param updateDomains int

param avSetSKU string

resource availabilitySet 'Microsoft.Compute/availabilitySets@2024-07-01' = {
  name: toLower(availabilitySetName)
  location: location
  tags: tags
  properties: {
    platformFaultDomainCount: faultDomains
    platformUpdateDomainCount: updateDomains
  }
  sku: {
    name: avSetSKU
  }
  
}

@description('The resource ID of the deployed Availability Set.')
output avsetId string = availabilitySet.id
