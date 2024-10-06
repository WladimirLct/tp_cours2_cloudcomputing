resource "random_string" "random" {
    length  = 8
    special = false
    upper   = false
}

resource "azurerm_resource_group" "api" {
    location = var.location
    name     = "course-2-rg-${random_string.random.result}"
}

resource "azurerm_service_plan" "api" {
    name                = "webapp-service-plan"
    resource_group_name = azurerm_resource_group.api.name
    location            = azurerm_resource_group.api.location
    os_type             = "Linux"
    sku_name            = "B1"
}

resource "azurerm_linux_web_app" "api" {
    name                = "webapp-${random_string.random.result}"
    location            = azurerm_resource_group.api.location
    resource_group_name = azurerm_resource_group.api.name
    service_plan_id     = azurerm_service_plan.api.id

    site_config {
      application_stack {
        python_version = "3.9"
      }
    }

    app_settings = {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    }
}

resource "azurerm_app_service_source_control" "api" {
  app_id         =  azurerm_linux_web_app.api.id
  repo_url       = "https://github.com/WladimirLct/tp_cours2_cloudcomputing"
  branch         = "main"
}