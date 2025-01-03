@description('The name of the Virtual Machine.')
param virtualMachineName string

@description('The location of the Virtual Machine.')
param location string

@description('Tags to be applied to the virtual machine.')
param tags object = {}

@description('The name of the Network Interface associated with the VM.')
param networkInterfaceName string 

@description('The size of the Virtual Machine.')
param virtualMachineSize string

@description('The type of storage for the OS disk.')
@allowed(['Standard_LRS', 'Premium_LRS'])
param osDiskType string

@description('The delete option for the OS disk.')
@allowed(['Delete', 'Detach'])
param osDiskDeleteOption string

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

@description('Enable hotpatching for the VM.')
param enableHotpatching bool = false

@description('Patch mode for the VM.')
@allowed(['AutomaticByOS', 'AutomaticByPlatform', 'Manual'])
param patchMode string = 'AutomaticByOS'

@description('Admin username for the VM.')
param adminUsername string

@description('Admin password for the VM.')
@secure()
param adminPassword string

@description('Storage URI for diagnostics.')
param storageUri string

@description('Name of the OS disk.')
param osDiskName string

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: virtualMachineName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        name: osDiskName
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSKU
        version: imageVersion
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', networkInterfaceName)
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: enableHotpatching
          patchMode: patchMode
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageUri
      }
    }
  }
  plan: empty(imageSKU) || empty(imageOffer) || empty(imagePublisher) ? null : {
    name: imageSKU
    publisher: imagePublisher
    product: imageOffer
  }
}
