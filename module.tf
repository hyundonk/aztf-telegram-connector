
# storage account to store function app package. The function app package will contain only proxies.json and host.json

locals {
  prefix = var.prefix
}

resource "azurerm_template_deployment" "custom_connector" {
  name                  = "${local.prefix}-telegram-connector-v2"
  resource_group_name   = var.resource_group_name

  template_body         = file("${path.module}/${var.customapi_template_path}")

  parameters = {
    "customapi_name"    = var.customapi_name
    "icon_uri"          = format("data:image/png;base64,%s", filebase64("${path.module}/${var.customapi_logo_path}"))
    "location"          = var.location
    "telegram_api_hostname" = var.telegram_api_hostname
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
