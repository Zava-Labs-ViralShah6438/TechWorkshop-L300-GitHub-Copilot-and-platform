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
