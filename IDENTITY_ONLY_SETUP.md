# Identity-Only Authentication Setup Guide

This document describes the identity-only authentication implementation for the ZavaStorefront application's integration with Azure AI Foundry (Microsoft Foundry).

## Overview

The application has been configured to use **Microsoft Entra ID Managed Identity** exclusively for authenticating to Azure AI Foundry. API keys have been completely removed from the codebase, configuration, and infrastructure.

## Architecture

### Authentication Flow
```
App Service (Managed Identity)
    ↓ (DefaultAzureCredential)
Azure AI Foundry Endpoint
    ↓ (Microsoft Entra ID authentication)
Phi-4 Model
```

### Components

1. **App Service**: `zavastorewebappdev-linux`
   - SystemAssigned Managed Identity enabled
   - Principal ID: `9e4fe94e-dd25-483d-b852-5023c844f894`

2. **Azure AI Foundry**: `shahviral6438-2744-resource`
   - Kind: `AIServices`
   - `disableLocalAuth: true` (API keys disabled)
   - Only accepts Microsoft Entra ID authentication

3. **RBAC**: Cognitive Services User Role
   - Role ID: `a97b65f3-24c7-4388-baec-2e87135dc908`
   - Assigned to: App Service managed identity
   - Scope: Foundry resource

## Implementation Details

### Code Changes

**Services/ChatService.cs**
```csharp
_client = new ChatCompletionsClient(
    new Uri(endpoint),
    new DefaultAzureCredential()  // Uses managed identity - no API keys
);
```

**Dependencies**
- `Azure.AI.Inference` (v1.0.0-beta.5)
- `Azure.Identity` (v1.13.1)

### Configuration

**appsettings.json** (non-sensitive configuration only)
```json
"FoundrySettings": {
  "Phi4EndpointUrl": "",
  "DeploymentName": "Phi-4"
}
```

**App Service Configuration**
- `FoundrySettings__Phi4EndpointUrl`: Set via Azure portal or GitHub workflow
- `FoundrySettings__DeploymentName`: "Phi-4"
- NO API KEY stored anywhere

### Infrastructure as Code

**infra/modules/foundry.bicep**
```bicep
resource foundryAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: foundryName
  location: location
  kind: 'AIServices'
  properties: {
    disableLocalAuth: true  // Enforces identity-only authentication
  }
  identity: {
    type: 'SystemAssigned'
  }
}
```

**infra/modules/foundryRoleAssignment.bicep**
```bicep
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(foundryAccount.id, principalId, roleDefinitionId)
  scope: foundryAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
```

**infra/main.bicep**
- Provisions Foundry with `disableLocalAuth: true`
- Creates role assignment for App Service → Foundry access
- Outputs Foundry endpoint URLs for configuration

## Deployment Steps

### 1. Deploy Infrastructure

```powershell
# Deploy Bicep templates to create/update resources
az deployment group create `
  --resource-group rg-zavalabs-dev `
  --template-file infra/main.bicep `
  --parameters infra/main.parameters.json
```

This will:
- Create/update Azure AI Foundry with identity-only authentication
- Assign Cognitive Services User role to App Service managed identity
- Output Foundry endpoint URLs

### 2. Verify Foundry Configuration

```powershell
# Check that API keys are disabled
az cognitiveservices account show `
  --name shahviral6438-2744-resource `
  --resource-group rg-zavalabs-dev `
  --query "properties.disableLocalAuth"
# Expected output: true
```

### 3. Configure App Service Settings

Option A: Using Bicep outputs (recommended)
```powershell
# Get Foundry endpoint from Bicep deployment
$deployment = az deployment group show `
  --resource-group rg-zavalabs-dev `
  --name <deployment-name> `
  --query "properties.outputs.foundryModelEndpoint.value" -o tsv

# Configure App Service
az webapp config appsettings set `
  --name zavastorewebappdev-linux `
  --resource-group rg-zavalabs-dev `
  --settings FoundrySettings__Phi4EndpointUrl="$deployment"
```

Option B: Using existing GitHub workflow
- Workflow uses GitHub secret `FOUNDRY_ENDPOINT_URL`
- Update the secret if endpoint changes
- Workflow automatically configures app settings on deployment

### 4. Verify Role Assignment

```powershell
# Check role assignment
az role assignment list `
  --assignee 9e4fe94e-dd25-483d-b852-5023c844f894 `
  --scope /subscriptions/{subscription-id}/resourceGroups/rg-zavalabs-dev/providers/Microsoft.CognitiveServices/accounts/shahviral6438-2744-resource
```

### 5. Test Application

1. Deploy application code to App Service
2. Navigate to `/Chat` page
3. Send a test message
4. Verify successful response from Phi-4 model

## Security Validation

### Verification Checklist

- [ ] `disableLocalAuth: true` on Foundry resource
- [ ] No API keys in source code
- [ ] No API keys in appsettings.json
- [ ] No API keys in user secrets
- [ ] No API keys in App Service configuration
- [ ] No API keys in GitHub secrets/variables
- [ ] No API keys in GitHub workflow
- [ ] Managed identity enabled on App Service
- [ ] Cognitive Services User role assigned
- [ ] DefaultAzureCredential used in code
- [ ] Application successfully communicates with Foundry

### Test Identity-Only Access

```powershell
# Verify no keys can be retrieved (should fail)
az cognitiveservices account keys list `
  --name shahviral6438-2744-resource `
  --resource-group rg-zavalabs-dev
# Expected: Error indicating keys are disabled
```

## Troubleshooting

### Common Issues

**Issue**: 401 Unauthorized errors
- **Cause**: Role assignment not propagated yet
- **Solution**: Wait 5-10 minutes for Azure RBAC to propagate, or restart App Service

**Issue**: DefaultAzureCredential fails locally
- **Cause**: Not signed in to Azure CLI
- **Solution**: Run `az login` before testing locally

**Issue**: Application can't find endpoint
- **Cause**: App setting not configured
- **Solution**: Verify `FoundrySettings__Phi4EndpointUrl` is set in App Service configuration

## References

- [Azure Managed Identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/)
- [Azure AI Services Authentication](https://learn.microsoft.com/en-us/azure/ai-services/authentication)
- [DefaultAzureCredential](https://learn.microsoft.com/en-us/dotnet/api/azure.identity.defaultazurecredential)
- [Cognitive Services RBAC Roles](https://learn.microsoft.com/en-us/azure/ai-services/authentication#azure-rbac-roles)

## Next Steps

- [ ] Deploy Bicep templates to production
- [ ] Update GitHub workflow to use Bicep outputs (optional)
- [ ] Remove `FOUNDRY_ENDPOINT_URL` GitHub secret (if using Bicep outputs)
- [ ] Document incident response for identity issues
- [ ] Set up monitoring for authentication failures
