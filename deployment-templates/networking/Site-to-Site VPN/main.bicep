param location string
param locationShort string
param tags object
param deploymentPrefix string
param deploymentInstance string
param deploymentType string

var virtualNetworkName = '${deploymentPrefix}-vnet-${deploymentType}-${locationShort}-${deploymentInstance}'
param virtualNetworkAddressRange string
param subnets array
param DNSServerAddress array = []

var nsgName = '${deploymentPrefix}-nsg-${deploymentType}-${locationShort}-${deploymentInstance}'
param securityRules array = []

var publicIpName = '${deploymentPrefix}-pip-${deploymentType}-${locationShort}-${deploymentInstance}'
param publicIpsku string
param publicIPAllocationMethod string

var vpnGatewayName = '${deploymentPrefix}-vpngw-${deploymentType}-${locationShort}-${deploymentInstance}'
param gatewaySku string
param gatewayType string
param vpnType string

var localGatewayName = '${deploymentPrefix}-localgw-${deploymentType}-${locationShort}-${deploymentInstance}'
param localGatewayIpAddress string
param localAddressPrefixes array


var connectionName = '${deploymentPrefix}-connection-${deploymentType}-${locationShort}-${deploymentInstance}'
param enableBgp bool



// ############### MODULES ############### //

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
}

module nsg 'modules/nsg.bicep' = {
  name: 'nsgDeploy'
  params: {
  location: location
  nsgName: nsgName
  securityRules: securityRules
  }
}

module publicIp 'modules/publicIp.bicep' = {
  name: 'PipDeploy'
  params: {
    location: location
    publicIpName: publicIpName
    publicIpsku: publicIpsku
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

module vpnGateway 'modules/vpnGateway.bicep' = {
  name: 'vpnDeploy'
  params: {
    location: location
    vpnGatewayName: vpnGatewayName
    gatewaySku: gatewaySku
    gatewayType: gatewayType
    publicIpId: publicIp.outputs.publicIpId
    vpnType: vpnType
    gatewaySubnetId: vnet.outputs.gatewaySubnetId
  }
}

module localGateway 'modules/localGateway.bicep' = {
  name: 'localGWDeploy'
  params: {
    location: location
    localGatewayName: localGatewayName
    localAddressPrefixes: localAddressPrefixes
    localGatewayIpAddress: localGatewayIpAddress
  }
}

module vpnConfiguration 'modules/vpnConfigure.bicep' = {
  name: 'configDeploy'
  params: {
    location: location
    vpnGatewayName: vpnGatewayName
    connectionName: connectionName
    vpnGatewayId: vpnGateway.outputs.id
    localGatewayId: localGateway.outputs.id
    enableBgp: enableBgp

  }
}
// ############### Outputs ############### //

//output vnetid string = vnet.outputs.id


