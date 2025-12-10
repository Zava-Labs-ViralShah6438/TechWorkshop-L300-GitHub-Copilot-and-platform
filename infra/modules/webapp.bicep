param webAppName string
param location string
param planId string
param acrLoginServer string
param managedIdentity bool = true

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  identity: managedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    serverFarmId: planId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/zavastorefront:latest'
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
      ]
    }
  }
}

output webAppId string = webApp.id
output managedIdentityPrincipalId string = webApp.identity.principalId
