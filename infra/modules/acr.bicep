param acrName string
param location string
param sku string = 'Basic'

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: sku
  }
}

output acrId string = acr.id
output loginServer string = acr.properties.loginServer
