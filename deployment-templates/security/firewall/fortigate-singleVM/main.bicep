@description('Indicates whether to create a new VNet or use an existing one')
@allowed([
  'new'
  'existing'
])
param vnetDeploymentOption string

@description('deployment environment')
@allowed([
  'PROD'
  'DEV'
  'TEST'
  'DEMO'
])
param environment string

@description('Virtual Machine size selection - must be F4 or other instance that supports 4 NICs')
@allowed([
  'Standard_F2s'
  'Standard_F4s'
  'Standard_F8s'
  'Standard_DS3_v2'
  'Standard_DS4_v2'
  'Standard_DS5_v2'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
])
param VMSize string

@description('Username for the Virtual Machine')
param adminUsername string

@description('Password for the Virtual Machine')
@secure()
param adminPassword string

@description('Fortigate FW Version')
@allowed([
  '6.4.13'
  '7.0.12'
  '7.2.5'
  '7.2.6'
  '7.4.0'
  '7.4.1'
  'latest'
])
param fortiGateImageVersion string
param location string
param virtualNetworkPrefix string
param subnets array
param publicIPAddressType string
param acceleratedNetworking string
param fortiGateImageSKU string
param imagePublisher string
param imageOffer string
param FortigateVMname string
param vmDiagStoreKind string
param vmDiagStoreSKU string

// ########## Variables ##########

@description(' Tags will be added to all resources deployed')
var tagValues = {
  Environment: environment
}
var virtualNetworkName = '${FortigateVMname}-VNET-01'
var NSGName = '${FortigateVMname}-NSG-01'
var publicIPName = '${FortigateVMname}-PiP-01'
var networkAdpter1Name = '${FortigateVMname}-NIC-01'
var networkAdpter2Name = '${FortigateVMname}-NIC-02'
var randomNumbers = substring(uniqueString(resourceGroup().id), 0, 4)
var diagnosticsStorageAccountName = 'vmdiagstore${randomNumbers}'
var routeTableName = '${FortigateVMname}-RT-01'


// ########## Resources ##########

@description('Create a storage account for VM diagnostics')
resource vmDiagStorage 'Microsoft.Storage/storageAccounts@2023-01-01' ={
  name: toLower(diagnosticsStorageAccountName)
  location: location
  tags: tagValues
  kind: vmDiagStoreKind
  sku: {
    name: vmDiagStoreSKU
  }
}

@description('Create a route table for the protected subnet')
resource routeTableProtectedName 'Microsoft.Network/routeTables@2020-04-01' = {
  name: routeTableName
  tags: tagValues
  location: location
  properties: {
    routes: [
      {
        name: 'VirtualNetwork'
        properties: {
          addressPrefix: virtualNetworkPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: subnet2IP
        }
      }
      {
        name: 'Subnet'
        properties: {
          addressPrefix: subnet3Prefix
          nextHopType: 'VnetLocal'
        }
      }
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: subnet2IP
        }
      }
    ]
  }
}

@description('Create a virtual network for the Firewall VM')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = if (vnetDeploymentOption == 'new') {
  name: virtualNetworkName
  location: location
  tags: tagValues
  dependsOn: [
    routeTableProtectedName
  ]
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    subnets:[for subnet in subnets: {
      name: subnet.name
      properties: {
          addressPrefix: subnet.prefix
          routeTable: contains(subnet, 'routeTable') && !empty(subnet.routeTable) ? {
            id: routeTableProtectedName.id
          } : null
        }
      }]
  }
}

@description('Create a network security group for the Firewall VM')
resource NSG 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  tags: tagValues
  name: NSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAllInbound'
        properties: {
          description: 'Allow all in'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAllOutbound'
        properties: {
          description: 'Allow all out'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 105
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  tags: tagValues
  name: publicIPName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    
  }
}

var subnet1Prefix = subnets[0].prefix
// Split the CIDR subnet into the IP address and prefix length
var parts = split(subnet1Prefix, '/')
var ipAddress = parts[0]
// Convert the IP address to an array of numbers
var ipArray = split(ipAddress, '.')
// Calculate the first usable IP address, accounting for Azure's reserved addresses
var subnet1IP = '${ipArray[0]}.${ipArray[1]}.${ipArray[2]}.${int(ipArray[3]) + 5}'

var subnet2Prefix = subnets[1].prefix
// Split the CIDR subnet into the IP address and prefix length
var parts2 = split(subnet2Prefix, '/')
var ipAddress2 = parts2[0]
// Convert the IP address to an array of numbers
var ipArray2 = split(ipAddress2, '.')
// Calculate the first usable IP address, accounting for Azure's reserved addresses
var subnet2IP = '${ipArray2[0]}.${ipArray2[1]}.${ipArray2[2]}.${int(ipArray2[3]) + 5}'

var subnet3Prefix = subnets[2].prefix
// Split the CIDR subnet into the IP address and prefix length
var parts3 = split(subnet3Prefix, '/')
var ipAddress3 = parts3[0]
// Convert the IP address to an array of numbers
var ipArray3 = split(ipAddress3, '.')
// Calculate the first usable IP address, accounting for Azure's reserved addresses
var subnet3IP = '${ipArray3[0]}.${ipArray3[1]}.${ipArray3[2]}.${int(ipArray3[3]) + 5}'

resource networkAdapter1 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  tags: tagValues
  name: networkAdpter1Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: subnet1IP
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, 'ExternalSubnet')
          }
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: NSG.id
    }
  }
}

resource networkAdapter2 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  tags: tagValues
  name: networkAdpter2Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: subnet2IP
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, 'InternalSubnet')
          }
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: NSG.id
    }
  }
}

resource firewallVM 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: FortigateVMname
  tags: tagValues
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  plan: {
    name: fortiGateImageSKU
    publisher: imagePublisher
    product: imageOffer
  }
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    osProfile: {
      computerName: FortigateVMname
      adminUsername: adminUsername
      adminPassword: adminPassword
      //customData: fgaCustomData
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: vmDiagStorage.properties.primaryEndpoints.blob
      }
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: fortiGateImageSKU
        version: fortiGateImageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        name: '${FortigateVMname}-OSDisk-01'
      }
      dataDisks: [
        {
          diskSizeGB: 30
          lun: 0
          createOption: 'Empty'
          name: '${FortigateVMname}-DataDisk-01'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: networkAdapter1.id
        }
        {
          properties: {
            primary: false
          }
          id: networkAdapter2.id
        }
      ]
    }
  }
}
