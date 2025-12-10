param planName string
param webAppName string
param location string
param acrLoginServer string
param workspaceId string
param imageName string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: planName
  location: location
  kind: 'Linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  tags: {
    'azd-service-name': 'src'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${imageName}'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'WEBSITES_PORT'
          value: '80'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: workspaceId
        }
      ]
      alwaysOn: false
    }
  }
}

output webAppId string = webApp.id
output managedIdentityPrincipalId string = webApp.identity.principalId
output planId string = appServicePlan.id
