@description('The name of the Network Security Group.')
param nsgName string

@description('The location of the Network Security Group.')
param location string

@description('Tags to be applied to the virtual network.')
param tags object = {}

@description('An array of security rules to configure in the NSG.')
param securityRules array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      for rule in securityRules: {
        name: rule.name
        properties: {
          priority: rule.priority
          direction: rule.direction
          access: rule.access
          protocol: rule.protocol
          sourcePortRange: rule.sourcePortRange
          destinationPortRange: rule.destinationPortRange
          sourceAddressPrefix: rule.sourceAddressPrefix
          destinationAddressPrefix: rule.destinationAddressPrefix
        }
      }
    ]
  }
}

@description('The resource ID of the deployed Network Security Group.')
output nsgId string = nsg.id
