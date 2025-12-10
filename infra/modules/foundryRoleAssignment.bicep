// Role Assignment Module for Foundry Access
param principalId string
param foundryName string
param roleDefinitionId string = 'a97b65f3-24c7-4388-baec-2e87135dc908' // Cognitive Services User

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: foundryName
}

// Use a deterministic GUID based on subscription, resource, principal, and role
// This ensures the same assignment always gets the same name
var roleAssignmentName = guid(subscription().id, foundryAccount.id, principalId, roleDefinitionId)

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: foundryAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output roleAssignmentId string = roleAssignment.id
output roleAssignmentName string = roleAssignment.name
