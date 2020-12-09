
# storage account to store function app package. The function app package will contain only proxies.json and host.json

locals {
  prefix = var.prefix
}

resource "random_string" "random_postfix" {
    length  = 3
    upper   = false
    special = false
}

resource "azurerm_storage_account" "example" {
  name                     = "${local.prefix}telegramftsa${random_string.random_postfix.result}"
  location                = var.location
  resource_group_name     = var.resource_group_name

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "releases"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "appcode" {
  name                    = var.function_zip_path
  storage_account_name    = azurerm_storage_account.example.name
  storage_container_name  = azurerm_storage_container.container.name

  type = "Block"

  source = "${path.module}/${var.function_zip_path}"
}

data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.example.primary_connection_string

  https_only  = true
  start       = "2020-12-01"
  expiry      = "2025-11-30"
  
  resource_types {
    object    = true
    container = false
    service   = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }
 
  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}


resource "azurerm_app_service_plan" "example" {
  name                = "${local.prefix}-telegram-alert-consumption-plan"
 
  location                = var.location
  resource_group_name     = var.resource_group_name

  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

}

resource "azurerm_function_app" "example" {
  name                = "${local.prefix}-telegram-proxy"
 
  location                = var.location
  resource_group_name     = var.resource_group_name

  app_service_plan_id        = azurerm_app_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  app_settings = {
    https_only                = true          
    FUNCTIONS_WORKER_RUNTIME  = "dotnet"
    HASH                      = base64encode(filesha256("${path.module}/${var.function_zip_path}"))
    WEBSITE_RUN_FROM_PACKAGE = "https://${azurerm_storage_account.example.name}.blob.core.windows.net/${azurerm_storage_container.container.name}/${azurerm_storage_blob.appcode.name}${data.azurerm_storage_account_sas.sas.sas}"
  }
}

resource "azurerm_template_deployment" "custom_connector" {
  name                  = "${local.prefix}-telegram-connector"
  resource_group_name   = var.resource_group_name

  template_body         = file("${path.module}/${var.customapi_template_path}")

  parameters = {
    "customapi_name"    = var.customapi_name
    "icon_uri"          = format("data:image/png;base64,%s", filebase64("${path.module}/${var.customapi_logo_path}"))
    "location"          = var.location
    "function_hostname" = azurerm_function_app.example.default_hostname
  }

  deployment_mode       = "Incremental"
}

resource "azurerm_template_deployment" "logicapp_workflow" {
  name                  = "${local.prefix}-workflow-telegram-alert"
  resource_group_name   = var.resource_group_name

  template_body         = file("${path.module}/${var.logicapp_workflow_template_path}")

  parameters = {
    "workflow_name"     = "${local.prefix}-workflow-telegram-alert"
    "connection_name"   = azurerm_template_deployment.custom_connector.outputs.connector_name
    "connection_id"     = azurerm_template_deployment.custom_connector.outputs.connection_id
    "customApi_id"      = azurerm_template_deployment.custom_connector.outputs.customApi_id
    "chat_id"           = var.telegram_chat_id
    "location"          = var.location
    "api_key"           = var.telegram_api_key
  }

  deployment_mode       = "Incremental"
}
