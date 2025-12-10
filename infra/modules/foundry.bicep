// Azure AI Foundry / Cognitive Services Account Module
param foundryName string
param location string
param sku string = 'S0'
param kind string = 'AIServices'

// Enforce identity-only authentication
param disableLocalAuth bool = true
param publicNetworkAccess string = 'Enabled'

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: foundryName
  location: location
  kind: kind
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: foundryName
    publicNetworkAccess: publicNetworkAccess
    
    // Disable API key authentication - enforce Entra ID only
    disableLocalAuth: disableLocalAuth
    
    // Network configuration
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    
    // Enable dynamic throttling for better performance
    dynamicThrottlingEnabled: true
  }
}

output foundryId string = foundryAccount.id
output foundryName string = foundryAccount.name
output foundryEndpoint string = foundryAccount.properties.endpoint
output foundryModelEndpoint string = 'https://${foundryAccount.properties.customSubDomainName}.services.ai.azure.com/models'
output foundryIdentityPrincipalId string = foundryAccount.identity.principalId
