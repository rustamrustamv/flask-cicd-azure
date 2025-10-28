# outputs.tf

# This output will show us the ACR login server name
# We need this to tag our Docker image (e.g., acrflaskapp123.azurecr.io/my-flask-app)
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

# This output will show us the ACR admin credentials
# Our GitHub Action will use these to push the image
output "acr_admin_username" {
  value     = azurerm_container_registry.acr.admin_username
  sensitive = true
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

# This output will be the final URL of our deployed application
output "webapp_default_hostname" {
  value = azurerm_linux_web_app.webapp.default_hostname
}