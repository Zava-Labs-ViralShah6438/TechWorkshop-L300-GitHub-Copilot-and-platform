# GitHub Actions Deployment Setup

## Overview

This workflow builds a Docker container from the .NET application and deploys it to Azure App Service via Azure Container Registry.

## Required GitHub Secrets

Configure these secrets in your repository settings (`Settings` > `Secrets and variables` > `Actions` > `New repository secret`):

### `AZURE_CREDENTIALS`
Azure service principal credentials in JSON format:
```json
{
  "clientId": "<client-id>",
  "clientSecret": "<client-secret>",
  "subscriptionId": "<subscription-id>",
  "tenantId": "<tenant-id>"
}
```

**To create:**
```bash
az ad sp create-for-rbac --name "github-actions-zavastorefront" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group-name> \
  --sdk-auth
```

### `ACR_USERNAME`
Your Azure Container Registry admin username.

**To retrieve:**
```bash
az acr credential show --name <acr-name> --query username -o tsv
```

### `ACR_PASSWORD`
Your Azure Container Registry admin password.

**To retrieve:**
```bash
az acr credential show --name <acr-name> --query "passwords[0].value" -o tsv
```

## Required GitHub Variables

Configure these variables in your repository settings (`Settings` > `Secrets and variables` > `Actions` > `Variables` tab > `New repository variable`):

### `AZURE_WEBAPP_NAME`
The name of your Azure App Service web app (e.g., `zavastorefront-dev`)

### `ACR_LOGIN_SERVER`
Your Azure Container Registry login server (e.g., `myregistry.azurecr.io`)

**To retrieve:**
```bash
az acr show --name <acr-name> --query loginServer -o tsv
```

## Workflow Triggers

- **Push to main branch**: Automatically builds and deploys
- **Manual trigger**: Use `Actions` tab > `Build and Deploy to Azure App Service` > `Run workflow`

## Notes

- Ensure Azure Container Registry admin user is enabled:
  ```bash
  az acr update --name <acr-name> --admin-enabled true
  ```
- The App Service must have AcrPull permissions on the Container Registry (configured via managed identity in your Bicep templates)
