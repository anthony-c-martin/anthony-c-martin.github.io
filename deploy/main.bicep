targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'blog'
  location: deployment().location
}

module blog './blog.bicep' = {
  scope: rg
  name: 'blog-module'
}

output stgAccName string = blog.outputs.stgAccName
output stgAccKey string = blog.outputs.stgAccKey
