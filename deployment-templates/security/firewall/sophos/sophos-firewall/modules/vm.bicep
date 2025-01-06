@description('The name of the Virtual Machine.')
param virtualMachineName string

@description('The location of the Virtual Machine.')
param location string

@description('Tags to be applied to the virtual machine.')
param tags object = {}

@description('The size of the Virtual Machine.')
param virtualMachineSize string

@description('Publisher of the VM image.')
param imagePublisher string

@description('Offer of the VM image.')
param imageOffer string

@description('SKU of the VM image.')
param imageSKU string

@description('Version of the VM image.')
param imageVersion string = 'latest'

@description('Delete option for the NIC.')
@allowed(['Delete', 'Detach'])
param nicDeleteOption string = 'Delete'

@description('Admin username for the VM.')
param adminUsername string

@description('Admin password for the VM.')
@secure()
param adminPassword string

@description('Storage URI for diagnostics.')
param storageUri string

@description('An array of network interface IDs to associate with the VM.')
param networkInterfaceIds array

@description('The resource ID of the Availability Set.')
param availabilitySetId string

param osDiskName string
param dataDiskName string

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: virtualMachineName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  plan: {
    name: imageSKU
    publisher: imagePublisher
    product: imageOffer
  }
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
  osProfile: {
    computerName: virtualMachineName
    adminUsername: adminUsername
    adminPassword: adminPassword
    }
  diagnosticsProfile: {
    bootDiagnostics: {
      enabled: true
      storageUri: storageUri
      }
    }
  storageProfile: {
    imageReference: {
      publisher: imagePublisher
      offer: imageOffer
      sku: imageSKU
      version: imageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        name: osDiskName
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      dataDisks: [
        {
          createOption: 'FromImage'
          name: dataDiskName
          lun: 0
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
        }
      ]
      }
    networkProfile: {
      networkInterfaces: [ for nicId in networkInterfaceIds: {
          id: nicId.id
          properties: {
            deleteOption: nicDeleteOption
            primary: nicId.primary
          }
        }]
    }
    availabilitySet: {
      id: availabilitySetId
    }
    
    
  }
}
