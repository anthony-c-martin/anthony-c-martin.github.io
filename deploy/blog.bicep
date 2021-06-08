var domainName = 'anthonymart.in'
var resourceBaseName = 'blog'

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${resourceBaseName}${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

var storageHostname = replace(replace(storage.properties.primaryEndpoints.web, 'https://', ''), '/', '')

resource cdnProfile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: resourceBaseName
  location: 'Global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource cdnEnpoint 'Microsoft.Cdn/profiles/endpoints@2020-09-01' = {
  parent: cdnProfile
  name: resourceBaseName
  location: 'Global'
  properties: {
    originHostHeader: storageHostname
    isCompressionEnabled: true
    isHttpAllowed: false
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    origins: [
      {
        name: replace(storageHostname, '.', '-')
        properties: {
          hostName: storageHostname
          httpPort: 80
          httpsPort: 443
          originHostHeader: storageHostname
          priority: 1
          weight: 1000
          enabled: true
        }
      }
    ]
  }
}

resource cdnDomain 'Microsoft.Cdn/profiles/endpoints/customdomains@2020-09-01' = {
  parent: cdnEnpoint
  name: replace(domainName, '.', '-')
  properties: {
    hostName: domainName
  }
}
