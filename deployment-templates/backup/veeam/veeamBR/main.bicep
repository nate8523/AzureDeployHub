@description('The Azure region where the resources will be deployed.')
param location string

@description('A short identifier for the location, used in resource naming conventions (e.g., "eus" for East US).')
param locationShort string

@description('Tags to apply to all resources in the deployment.')
param tags object

@description('A prefix for naming resources, typically representing the application or project name.')
param deploymentPrefix string

@description('A unique instance identifier for the deployment (e.g., "01").')
param deploymentInstance string

@description('The type of deployment, used in resource naming (e.g., "web", "db").')
param deploymentType string

@description('The address range for the virtual network (e.g., "10.0.0.0/16").')
param virtualNetworkAddressRange string

@description('An array of subnets, including names, address ranges, and optional NSG assignments.')
param subnets array

@description('Optional list of DNS server IP addresses for the virtual network.')
param DNSServerAddress array = []

@description('An array of security rules to configure in the Network Security Group.')
param securityRules array = []

@description('The SKU for the public IP address (e.g., "Standard").')
param publicIpsku string

@description('The allocation method for the public IP address. Options are "Static" or "Dynamic".')
param publicIPAllocationMethod string

@description('The delete option for the public IP address. Options are "Delete" or "Detach".')
param publicIpDeleteOption string

@description('The SKU for the storage account.')
param storageAccountSKU string

@description('The kind of the storage account (e.g., "StorageV2").')
param storageAccountKind string

@description('The minimum TLS version for the storage account (e.g., "TLS1_2").')
param storageTLSversion string

@description('The name of the virtual machine.')
var virtualMachineName = '${deploymentPrefix}-vm-${deploymentType}-${deploymentInstance}'

@description('The size of the virtual machine (e.g., "Standard_B2s").')
param virtualMachineSize string

@description('The type of storage for the OS disk (e.g., "Standard_LRS" or "Premium_LRS").')
param osDiskType string

@description('The delete option for the OS disk. Options are "Delete" or "Detach".')
param osDiskDeleteOption string

@description('The publisher of the VM image (e.g., "Canonical").')
param imagePublisher string

@description('The offer of the VM image (e.g., "UbuntuServer").')
param imageOffer string

@description('The SKU of the VM image (e.g., "18.04-LTS").')
param imageSKU string

@description('The version of the VM image (e.g., "latest").')
param imageVersion string

@description('The delete option for the network interface. Options are "Delete" or "Detach".')
param nicDeleteOption string

@description('Whether to enable hotpatching on the VM.')
param enableHotpatching bool

@description('The patch mode for the VM. Options are "AutomaticByOS", "AutomaticByPlatform", or "Manual".')
param patchMode string

@description('The admin username for the VM.')
param adminUsername string

@description('The admin password for the VM.')
@secure()
param adminPassword string

@description('The name of the virtual network.')
var virtualNetworkName = '${deploymentPrefix}-vnet-${deploymentType}-${locationShort}-${deploymentInstance}'

@description('The name of the Network Security Group.')
var nsgName = '${deploymentPrefix}-nsg-${deploymentType}-${locationShort}-${deploymentInstance}'

@description('The name of the public IP address.')
var publicIpName = '${deploymentPrefix}-pip-${deploymentType}-${locationShort}-${deploymentInstance}'

@description('The name of the network interface.')
var nicName = '${deploymentPrefix}-nic-${deploymentType}-${locationShort}-${deploymentInstance}'

@description('The name of the storage account for VM boot diagnostics.')
var storageAccountName = toLower('${deploymentPrefix}boot${uniqueString(resourceGroup().id)}')

@description('The name of the OS disk.')
var osDiskName = '${deploymentPrefix}-osDisk-${deploymentType}-${locationShort}-${deploymentInstance}'

// ############### MODULES ############### //

module bootstore 'modules/vmdiagnostics.bicep' = {
  name: 'bootDeploy'
  params: {
    location: location
    tags: tags
    storageAccountName: storageAccountName
    storageAccountKind: storageAccountKind
    storageAccountSKU: storageAccountSKU
    storageTLSversion: storageTLSversion
  }
}

module nsg 'modules/nsg.bicep' = {
  name: 'nsgDeploy'
  params: {
    location: location
    tags: tags
    nsgName: nsgName
    securityRules: securityRules
  }
}

module vnet 'modules/vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    location: location
    tags: tags
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnets: subnets
    DNSServerAddress: DNSServerAddress
    nsgName: nsgName
  }
  dependsOn: [nsg]
}

module publicIp 'modules/publicIp.bicep' = {
  name: 'pipDeploy'
  params: {
    location: location
    tags: tags
    publicIpName: publicIpName
    publicIpsku: publicIpsku
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

module nic 'modules/nic.bicep' = {
  name: 'nicDeploy'
  params: {
    location: location
    tags: tags
    networkInterfaceName: nicName
    publicIpName: publicIpName
    virtualNetworkName: virtualNetworkName
    nsgName: nsgName
    subnetName: vnet.outputs.subnetNames[0]
    publicIpDeleteOption: publicIpDeleteOption
  }
  dependsOn: [
    publicIp
  ]
}

module vm 'modules/vm.bicep' = {
  name: 'vmDeploy'
  params: {
    location: location
    tags: tags
    virtualMachineName: virtualMachineName
    virtualMachineSize: virtualMachineSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSKU: imageSKU
    imageVersion: imageVersion
    osDiskName: osDiskName
    osDiskType: osDiskType
    osDiskDeleteOption: osDiskDeleteOption
    networkInterfaceName: nicName
    nicDeleteOption: nicDeleteOption
    enableHotpatching: enableHotpatching
    patchMode: patchMode
    storageUri: bootstore.outputs.primaryBlobEndpoint
  }
  dependsOn: [nic]
}
