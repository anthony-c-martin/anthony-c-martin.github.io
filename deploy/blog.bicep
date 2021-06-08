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
  name: replace(domainName, '.', '-')
  location: 'Global'
  properties: {
    originHostHeader: storageHostname
    isHttpAllowed: false
    isHttpsAllowed: true
    isCompressionEnabled: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    optimizationType: 'GeneralWebDelivery'
    contentTypesToCompress: [
      'application/eot'
      'application/font'
      'application/font-sfnt'
      'application/javascript'
      'application/json'
      'application/opentype'
      'application/otf'
      'application/pkcs7-mime'
      'application/truetype'
      'application/ttf'
      'application/vnd.ms-fontobject'
      'application/xhtml+xml'
      'application/xml'
      'application/xml+rss'
      'application/x-font-opentype'
      'application/x-font-truetype'
      'application/x-font-ttf'
      'application/x-httpd-cgi'
      'application/x-javascript'
      'application/x-mpegurl'
      'application/x-opentype'
      'application/x-otf'
      'application/x-perl'
      'application/x-ttf'
      'font/eot'
      'font/ttf'
      'font/otf'
      'font/opentype'
      'image/svg+xml'
      'text/css'
      'text/csv'
      'text/html'
      'text/javascript'
      'text/js'
      'text/plain'
      'text/richtext'
      'text/tab-separated-values'
      'text/xml'
      'text/x-script'
      'text/x-component'
      'text/x-java-source'
    ]
    origins: [
      {
        name: replace(storageHostname, '.', '-')
        properties: {
          hostName: storageHostname
          originHostHeader: storageHostname
        }
      }
    ]
  }
}

// The following DNS records must exist before deploying this resource:
// * type: 'CNAME', name: 'www', data: 'anthonymart-in.azureedge.net.'
// * type: 'CNAME', name: 'cdnverify.www', data: 'cdnverify.anthonymart-in.azureedge.net.'
resource cdnDomain 'Microsoft.Cdn/profiles/endpoints/customdomains@2020-09-01' = {
  parent: cdnEnpoint
  name: replace(domainName, '.', '-')
  properties: {
    hostName: domainName
  }
}

output stgAccName string = storage.name
output stgAccKey string = listKeys(storage.id, storage.apiVersion).keys[0].value
