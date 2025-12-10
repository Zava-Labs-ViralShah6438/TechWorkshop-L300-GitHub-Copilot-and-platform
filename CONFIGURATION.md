# Configuration Setup

## Authentication Method

The application uses **Azure Managed Identity** for secure, keyless authentication to Azure AI Foundry. No API keys are required or stored in configuration.

## Local Development (User Secrets)

The application uses .NET User Secrets to store configuration locally. User secrets are stored outside the project directory and are never committed to source control.

### Setting Up User Secrets

1. Navigate to the `src` directory:
   ```powershell
   cd src
   ```

2. Set the required secrets:
   ```powershell
   dotnet user-secrets set "FoundrySettings:Phi4EndpointUrl" "https://your-resource.services.ai.azure.com/models"
   dotnet user-secrets set "FoundrySettings:DeploymentName" "Phi-4"
   ```

3. Verify your secrets:
   ```powershell
   dotnet user-secrets list
   ```

**Note for Local Development:** 
- When running locally, `DefaultAzureCredential` will use your Azure CLI credentials
- Ensure you're logged in: `az login`
- Your account must have "Cognitive Services User" role on the Foundry resource

## Production Deployment (Environment Variables)

For production deployments (Azure App Service, Docker, etc.), use environment variables:

### Azure App Service

Set application settings in the Azure Portal or via Azure CLI:

```bash
az webapp config appsettings set --name <app-name> --resource-group <resource-group> --settings \
  FoundrySettings__Phi4EndpointUrl="https://your-resource.services.ai.azure.com/models" \
  FoundrySettings__DeploymentName="Phi-4"
```

**Managed Identity Setup:**
1. Enable System-Assigned Managed Identity on your App Service (already configured in Bicep)
2. Grant the managed identity "Cognitive Services User" role on the Foundry resource:
   ```bash
   az role assignment create \
     --assignee <managed-identity-principal-id> \
     --role "Cognitive Services User" \
     --scope "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<foundry-name>"
   ```

### Docker / Container

Pass environment variables when running the container:

```bash
docker run -e FoundrySettings__Phi4EndpointUrl="https://your-resource.services.ai.azure.com/models" \
           -e FoundrySettings__DeploymentName="Phi-4" \
           your-image-name
```

For managed identity in containers, use Azure Container Instances or AKS with workload identity.

### GitHub Actions / CI/CD

1. Add secrets to your GitHub repository:
   - Go to Settings > Secrets and variables > Actions
   - Add the following repository secrets:
     - `FOUNDRY_ENDPOINT_URL`
     - `FOUNDRY_DEPLOYMENT_NAME`

2. Reference them in your workflow:
   ```yaml
   env:
     FoundrySettings__Phi4EndpointUrl: ${{ secrets.FOUNDRY_ENDPOINT_URL }}
     FoundrySettings__DeploymentName: ${{ secrets.FOUNDRY_DEPLOYMENT_NAME }}
   ```

## Configuration Priority

ASP.NET Core loads configuration in this order (later sources override earlier ones):
1. `appsettings.json`
2. `appsettings.{Environment}.json`
3. User Secrets (Development environment only)
4. Environment variables
5. Command-line arguments

## Security Best Practices

✅ **DO:**
- Use Managed Identity for Azure resource authentication
- Use User Secrets for local development
- Keep `appsettings.json` free of sensitive data
- Add sensitive files to `.gitignore`
- Grant least-privilege RBAC roles to managed identities

❌ **DON'T:**
- Use API keys when managed identity is available
- Commit secrets to source control
- Share `appsettings.Development.json` if it contains secrets
- Hardcode credentials in code files
- Grant excessive permissions to service principals

## How Managed Identity Works

1. **Azure App Service** has a system-assigned managed identity enabled
2. The identity is granted **"Cognitive Services User"** role on the Foundry resource
3. At runtime, `DefaultAzureCredential` automatically obtains a token from the managed identity
4. No API keys are stored or transmitted
5. Tokens are short-lived and automatically rotated by Azure
