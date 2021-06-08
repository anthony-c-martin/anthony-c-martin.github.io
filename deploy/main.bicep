targetScope = 'subscription'

param rgName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: deployment().location
}

module blog './blog.bicep' = {
  scope: rg
  name: 'blog-module'
}
