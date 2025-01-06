@description('The name of the storage account for VM diagnostics.')
param storageAccountName string

@description('The location of the storage account.')
param location string

@description('Tags to be applied to the storage account.')
param tags object

@description('The SKU for the storage account.')
@allowed([
  'Standard_LRS' 
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountSKU string

@description('The kind of the storage account.')
@allowed([
  'StorageV2'
  'Storage'
  'BlobStorage'
])
param storageAccountKind string

@description('The minimum TLS version for the storage account.')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param storageTLSversion string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: storageAccountKind
  sku: {
    name: storageAccountSKU
  }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: storageTLSversion
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
  }
}

@description('The primary Blob endpoint of the storage account.')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
