module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsightsModule'
  params: {
    appInsightsName: 'zavastoreappinsightsdev'
    location: location
    workspaceId: logAnalytics.outputs.workspaceId
  }
}
// Main Bicep template for ZavaStorefront Dev Infrastructure
param location string = 'westus3'
param acrName string
param workspaceName string
param planName string
param webAppName string
param imageName string
param foundryName string

module acr 'modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    acrName: acrName
    location: location
  }
}

module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalyticsModule'
  params: {
    workspaceName: workspaceName
    location: location
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appServiceModule'
  params: {
    planName: planName
    webAppName: webAppName
    location: location
    acrLoginServer: acr.outputs.loginServer
    workspaceId: logAnalytics.outputs.workspaceId
    imageName: imageName
  }
}

module acrRoleAssignment 'modules/roleassignment.bicep' = {
  name: 'acrRoleAssignment'
  params: {
    principalId: appService.outputs.managedIdentityPrincipalId
    acrName: acrName
  }
}

module foundry 'modules/foundry.bicep' = {
  name: 'foundryModule'
  params: {
    foundryName: foundryName
    location: location
    disableLocalAuth: true
  }
}

// Role assignment already exists - uncomment only if you need to recreate it
// module foundryRoleAssignment 'modules/foundryRoleAssignment.bicep' = {
//   name: 'foundryRoleAssignment'
//   params: {
//     foundryName: foundryName
//     principalId: appService.outputs.managedIdentityPrincipalId
//   }
//   dependsOn: [
//     foundry
//   ]
// }

output foundryModelEndpoint string = foundry.outputs.foundryModelEndpoint
output foundryEndpoint string = foundry.outputs.foundryEndpoint
output acrLoginServer string = acr.outputs.loginServer
output webAppId string = appService.outputs.webAppId
