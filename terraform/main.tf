# main.tf

# This block tells Terraform which "providers" we need.
# We are using the 'azurerm' provider to talk to Azure.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# This block configures the Azure provider.
# It will automatically use the environment variables (ARM_CLIENT_ID, etc.)
# that you set in the previous step.
provider "azurerm" {
  features {}
}

# This is our first "resource": a Resource Group.
# This is just a logical container to hold all our other services.
resource "azurerm_resource_group" "rg" {
  # This is a 'local' name for Terraform to refer to this resource
  # The actual resource name in Azure will be "rg-flaskapp-prod"

  name     = "rg-flaskapp-prod"
  location = "West Europe" # You can change this to a region near you
}

# 1. Create the Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "acrflaskapp${random_string.suffix.result}" # Must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true # Allows us to log in with a username/password
}

# 2. Create an App Service Plan (The "Server")
resource "azurerm_service_plan" "plan" {
  name                = "plan-flaskapp-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1" # B1 is the cheapest "Basic" tier, good for dev
}

# 3. Create the Web App (for Containers)
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-flaskapp-${random_string.suffix.result}" # Must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  # This identity is what gets the 'AcrPull' role later
  identity {
    type = "SystemAssigned"
  }

  # This tells the web app to get its code from a container
  site_config {
    always_on = false
    
    # This is the new part. We are telling Azure to create a
    # "blank" Python 3.9 "code" application. This is just a 
    # placeholder. Our CI/CD pipeline will update this later
    # to use our Docker container.
    application_stack {
      python_version = "3.9"
    }
  }

  # This block passes our environment variable to the container
  app_settings = {
    "GREETING"                        = "Hello from Azure!"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITES_PORT"                   = "8000" # Tell Azure our app is on port 8000
    # with the Managed Identity and role assignment.
  }
}

# -- Helper Resources --

# This creates a random 6-character string
# We use this to make our ACR and Web App names globally unique
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# This resource grants the Web App's Identity ("SystemAssigned" above)
# the 'AcrPull' role. This allows the Web App to pull images 
# from our Container Registry securely.
resource "azurerm_role_assignment" "acrpull_to_webapp" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
}

