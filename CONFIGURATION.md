# Configuration Setup

## Local Development (User Secrets)

The application uses .NET User Secrets to store sensitive configuration locally. User secrets are stored outside the project directory and are never committed to source control.

### Setting Up User Secrets

1. Navigate to the `src` directory:
   ```powershell
   cd src
   ```

2. Set the required secrets:
   ```powershell
   dotnet user-secrets set "FoundrySettings:Phi4EndpointUrl" "https://your-resource.services.ai.azure.com/models"
   dotnet user-secrets set "FoundrySettings:ApiKey" "your-api-key-here"
   dotnet user-secrets set "FoundrySettings:DeploymentName" "Phi-4"
   ```

3. Verify your secrets:
   ```powershell
   dotnet user-secrets list
   ```

## Production Deployment (Environment Variables)

For production deployments (Azure App Service, Docker, etc.), use environment variables:

### Azure App Service

Set application settings in the Azure Portal or via Azure CLI:

```bash
az webapp config appsettings set --name <app-name> --resource-group <resource-group> --settings \
  FoundrySettings__Phi4EndpointUrl="https://your-resource.services.ai.azure.com/models" \
  FoundrySettings__ApiKey="your-api-key-here" \
  FoundrySettings__DeploymentName="Phi-4"
```

### Docker / Container

Pass environment variables when running the container:

```bash
docker run -e FoundrySettings__Phi4EndpointUrl="https://your-resource.services.ai.azure.com/models" \
           -e FoundrySettings__ApiKey="your-api-key-here" \
           -e FoundrySettings__DeploymentName="Phi-4" \
           your-image-name
```

### GitHub Actions / CI/CD

1. Add secrets to your GitHub repository:
   - Go to Settings > Secrets and variables > Actions
   - Add the following repository secrets:
     - `FOUNDRY_ENDPOINT_URL`
     - `FOUNDRY_API_KEY`
     - `FOUNDRY_DEPLOYMENT_NAME`

2. Reference them in your workflow:
   ```yaml
   env:
     FoundrySettings__Phi4EndpointUrl: ${{ secrets.FOUNDRY_ENDPOINT_URL }}
     FoundrySettings__ApiKey: ${{ secrets.FOUNDRY_API_KEY }}
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
- Use User Secrets for local development
- Use Azure Key Vault or environment variables for production
- Keep `appsettings.json` free of sensitive data
- Add sensitive files to `.gitignore`

❌ **DON'T:**
- Commit API keys or secrets to source control
- Share `appsettings.Development.json` if it contains secrets
- Hardcode credentials in code files
