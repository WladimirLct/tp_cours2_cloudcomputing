resource "random_string" "random" {
    length  = 8
    special = false
    upper   = false
}

resource "azurerm_resource_group" "api" {
    location = var.location
    name     = "course-2-rg-${random_string.random.result}"
}

resource "azurerm_storage_account" "storage" {
  name                     = "course2storage${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.api.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  depends_on = [ 
    azurerm_resource_group.api
  ]
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"  # Allows public read access to blobs
}


resource "azurerm_cosmosdb_account" "cosmos_acc" {
  name                = "course-2"
  location            = var.location
  resource_group_name = "${azurerm_resource_group.api.name}"
  offer_type          = "Standard"
  kind                = "MongoDB"

  automatic_failover_enabled = true

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  depends_on = [ 
    azurerm_resource_group.api
   ]
}

resource "azurerm_cosmosdb_mongo_database" "cosmos_db" {
  name                = "course-2-mongodb"
  resource_group_name = azurerm_cosmosdb_account.cosmos_acc.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos_acc.name
  throughput          = 400
}


resource "azurerm_service_plan" "api" {
    name                = "webapp-service-plan"
    resource_group_name = azurerm_resource_group.api.name
    location            = azurerm_resource_group.api.location
    os_type             = "Linux"
    sku_name            = "B1"

    depends_on = [ 
        azurerm_resource_group.api
    ]
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
  repo_url       = "https://github.com/WladimirLct/tp_cours2_cloudcomputing.git"
  branch         = "main"
}