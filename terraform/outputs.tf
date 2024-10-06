output "api_url" {
  value = azurerm_linux_web_app.api.default_hostname
}

output "storage_url" {
    value = azurerm_storage_account.storage.primary_blob_endpoint
}