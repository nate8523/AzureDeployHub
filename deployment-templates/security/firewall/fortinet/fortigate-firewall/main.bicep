@description('The Azure region where the resources will be deployed.')
param location string

@description('A short identifier for the location, used in resource naming conventions.')
param locationShort string

@description('Tags to apply to all resources in the deployment.')
param tags object

@description('A prefix for naming resources, typically representing the application or project name.')
param deploymentPrefix string

@description('A unique instance identifier for the deployment.')
param deploymentInstance string

@description('The type of deployment, used in resource naming.')
param deploymentType string

@description('The address range for the virtual network.')
param virtualNetworkAddressRange string

@description('An array of subnets, including names, address ranges, and optional NSG assignments.')
param subnets array

@description('The SKU for the storage account.')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_ZRS', 'Premium_LRS'])
param storageAccountSKU string

@description('The kind of the storage account.')
@allowed(['StorageV2', 'Storage', 'BlobStorage'])
param storageAccountKind string

@description('The minimum TLS version for the storage account.')
@allowed(['TLS1_0', 'TLS1_1', 'TLS1_2'])
param storageTLSversion string

@description('An array of security rules to configure in the Network Security Group.')
param securityRules array

@description('The SKU for the public IP address.')
@allowed(['Standard', 'Basic'])
param publicIpsku string

@description('The allocation method for the public IP address.')
@allowed(['Static', 'Dynamic'])
param publicIPAllocationMethod string

@description('Network interface configurations.')
param networkInterfaces array

param acceleratedNetworking bool

param ipforwarding bool

@description('The size of the virtual machine.')
param virtualMachineSize string

@description('The publisher of the VM image.')
param imagePublisher string

@description('The offer of the VM image.')
param imageOffer string

@description('The SKU of the VM image.')
param imageSKU string

@description('The version of the VM image.')
param imageVersion string

@description('The delete option for the network interface.')
@allowed(['Delete', 'Detach'])
param nicDeleteOption string

@description('The admin username for the VM.')
param adminUsername string

@description('The admin password for the VM.')
@secure()
param adminPassword string

// ###### Variables ###### //

@description('The name of the virtual network.')
var routeTableName = toLower('${deploymentPrefix}-routeTable-${deploymentType}-${locationShort}-${deploymentInstance}')

@description('Name of the virtual network.')
var virtualNetworkName = toLower('${deploymentPrefix}-vnet-${deploymentType}-${locationShort}-${deploymentInstance}')

@description('The name of the public IP address.')
var publicIpName = '${deploymentPrefix}-pip-${deploymentType}-${locationShort}-${deploymentInstance}'

var subnet1Prefix = subnets[0].addressPrefix
// Split the CIDR subnet into the IP address and prefix length
var parts = split(subnet1Prefix, '/')
var ipAddress = parts[0]
// Convert the IP address to an array of numbers
var ipArray = split(ipAddress, '.')
// Calculate the first usable IP address, accounting for Azure's reserved addresses
var subnet1IP = '${ipArray[0]}.${ipArray[1]}.${ipArray[2]}.${int(ipArray[3]) + 5}'

var subnet2Prefix = subnets[1].addressPrefix
// Split the CIDR subnet into the IP address and prefix length
var parts2 = split(subnet2Prefix, '/')
var ipAddress2 = parts2[0]
// Convert the IP address to an array of numbers
var ipArray2 = split(ipAddress2, '.')
// Calculate the first usable IP address, accounting for Azure's reserved addresses
var subnet2IP = '${ipArray2[0]}.${ipArray2[1]}.${ipArray2[2]}.${int(ipArray2[3]) + 5}'

var subnet3Prefix = subnets[2].addressPrefix
// Split the CIDR subnet into the IP address and prefix length
var parts3 = split(subnet3Prefix, '/')
var ipAddress3 = parts3[0]
// Convert the IP address to an array of numbers
var ipArray3 = split(ipAddress3, '.')
// Calculate the first usable IP address, accounting for Azure's reserved addresses
var subnet3IP = '${ipArray3[0]}.${ipArray3[1]}.${ipArray3[2]}.${int(ipArray3[3]) + 5}'

@description('The name of the storage account for VM boot diagnostics.')
var storageAccountName = toLower('${substring(deploymentPrefix, 0, min(length(deploymentPrefix), 10))}boot${substring(uniqueString(resourceGroup().id), 0, 8)}')

@description('The name of the Network Security Group.')
var nsgName = '${deploymentPrefix}-nsg-${deploymentType}-${locationShort}-${deploymentInstance}'

@description('The name of the OS disk.')
var osDiskName = toLower('${deploymentPrefix}-osDisk-${deploymentType}-${locationShort}-${deploymentInstance}')

@description('The name of the data disk.')
var dataDiskName = toLower('${deploymentPrefix}-dataDisk-${deploymentType}-${locationShort}-${deploymentInstance}')

@description('The name of the virtual machine.')
var virtualMachineName = '${deploymentPrefix}-vm-${deploymentType}-${deploymentInstance}'

// ###### Modules ###### //

module routeTable 'modules/routeTable.bicep' = {
  name: 'routeTableDeploy'
  params: {
    location: location
    tags: tags
    routeTableName: routeTableName
    virtualNetworkAddressRange: virtualNetworkAddressRange
    subnet2IP: subnet2IP
    subnet3Prefix: subnet3Prefix
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
    routeTableid: routeTable.outputs.routeTableid
  }
}

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
    nsgId: nsg.outputs.nsgId
    acceleratedNetworking: acceleratedNetworking
    ipforwarding: ipforwarding
    subnet1IP: subnet1IP
    subnet2IP: subnet2IP
  }
  dependsOn: [
    vnet
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
    dataDiskName: dataDiskName
    networkInterfaceIds: [for nic in networkInterfaces: {
      id: resourceId('Microsoft.Network/networkInterfaces', toLower('${deploymentPrefix}-nic-${deploymentType}-${locationShort}-${nic.networkInterfaceName}'))  //fix this :)
      primary: nic.primary
  }]
    nicDeleteOption: nicDeleteOption
    storageUri: vmdiagnostics.outputs.primaryBlobEndpoint
  }
  dependsOn: [
    nics
    vnet
  ]
}
