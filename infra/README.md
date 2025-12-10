# ZavaStorefront Dev Infrastructure

This Bicep-based deployment provisions the following resources in Azure (westus3):

- **Azure Container Registry (ACR)**: Stores container images for the app.
- **Log Analytics Workspace**: Centralized logging and monitoring.
- **App Service Plan & Web App (Linux)**: Hosts the containerized storefront app.

## Modules
- `modules/acr.bicep`: Container Registry
- `modules/logAnalytics.bicep`: Log Analytics Workspace
- `modules/appService.bicep`: App Service Plan + Web App

## Deployment
1. Update `main.parameters.json` with your image/tag if needed.
2. Deploy with AZD or Azure CLI:
   ```sh
   az deployment group create --resource-group <rg-zavastore-dev-westus3> --template-file infra/main.bicep --parameters @infra/main.parameters.json
   ```
3. For AZD, see `azure.yaml` for workflow.

## Notes
- Minimal-cost SKUs for dev.
- Managed identity enabled for secure ACR pulls.
- Instrumentation key for monitoring is wired from Log Analytics.
