// params
//vmname
//password
//licence type, byol/payg
//domain name //.uksouth.cloudapp.azure.com
//storage account

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
param DNSServerAddress array

@description('An array of security rules to configure in the Network Security Group.')
param securityRules array

@description('The SKU for the public IP address (e.g., "Standard").')
param publicIpsku string

@description('The allocation method for the public IP address. Options are "Static" or "Dynamic".')
param publicIPAllocationMethod string

param networkInterfaces array

@description('The number of fault domains.')
param faultDomains int

@description('The number of update domains.')
param updateDomains int

param avSetSKU string

@description('The name of the virtual network.')
var virtualNetworkName = '${deploymentPrefix}-vnet-${deploymentType}-${locationShort}-${deploymentInstance}'

@description('The name of the Network Security Group.')
var nsgName = '${deploymentPrefix}-nsg-${deploymentType}-${locationShort}-${deploymentInstance}'

@description('The name of the public IP address.')
var publicIpName = '${deploymentPrefix}-pip-${deploymentType}-${locationShort}-${deploymentInstance}'

@description('The name of the Availability Set.')
var availabilitySetName = '${deploymentPrefix}-avset-${deploymentType}-${locationShort}-${deploymentInstance}'

module vnet 'modules/vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    location: location
    tags: tags
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnets: subnets
    DNSServerAddress: DNSServerAddress
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

module nics 'modules/nics.bicep' = {
  name: 'nicDeploy'
  params: {
    location: location
    tags: tags
    networkInterfaces: networkInterfaces
    virtualNetworkName: virtualNetworkName
    deploymentPrefix: deploymentPrefix
    deploymentType: deploymentType
    locationShort: locationShort
    publicIpId: publicIp.outputs.publicIpId
  }
  dependsOn: [
    vnet
  ]
}

module avset 'modules/avset.bicep' = {
  name: 'avsetDeploy'
  params: {
    location: location
    tags: tags
    availabilitySetName: availabilitySetName
    faultDomains: faultDomains
    updateDomains: updateDomains
    avSetSKU: avSetSKU
  }
}


@description('The SKU for the storage account.')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_ZRS', 'Premium_LRS'])
param storageAccountSKU string

@description('The kind of the storage account.')
@allowed(['StorageV2', 'Storage', 'BlobStorage'])
param storageAccountKind string

@description('The minimum TLS version for the storage account.')
@allowed(['TLS1_0', 'TLS1_1', 'TLS1_2'])
param storageTLSversion string

@description('The name of the storage account for VM boot diagnostics.')
var storageAccountName = toLower('${deploymentPrefix}boot${uniqueString(resourceGroup().id)}')

module vmdiagnostics 'modules/vmdiagnostics.bicep' = {
  name: 'diagnosticsDeploy'
  params: {
    location: location
    tags: tags
    storageAccountName: storageAccountName
    storageAccountKind: storageAccountKind
    storageAccountSKU: storageAccountSKU
    storageTLSversion: storageTLSversion
  }
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
    dataDiskName: dataDiskName
    networkInterfaceIds: [for nic in networkInterfaces: {
      id: resourceId('Microsoft.Network/networkInterfaces', toLower('${deploymentPrefix}-nic-${deploymentType}-${locationShort}-${nic.networkInterfaceName}'))  //fix this :)
      primary: nic.primary
  }]
    nicDeleteOption: nicDeleteOption
    storageUri: vmdiagnostics.outputs.primaryBlobEndpoint
    availabilitySetId: avset.outputs.avsetId
  }
  dependsOn: [
    nics
    vnet
  ]
}

@description('The name of the OS disk.')
var osDiskName = toLower('${deploymentPrefix}-osDisk-${deploymentType}-${locationShort}-${deploymentInstance}')

@description('The name of the Data disk.')
var dataDiskName = toLower('${deploymentPrefix}-dataDisk-${deploymentType}-${locationShort}-${deploymentInstance}')

@description('The name of the virtual machine.')
var virtualMachineName = '${deploymentPrefix}-vm-${deploymentType}-${deploymentInstance}'

@description('The size of the virtual machine (e.g., "Standard_B2s").')
param virtualMachineSize string

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

@description('The admin username for the VM.')
param adminUsername string

@description('The admin password for the VM.')
@secure()
param adminPassword string
