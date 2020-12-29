/*
output "function_hostname" {
  value = azurerm_function_app.example.default_hostname 
}

output "access_endpoint" {
  value = azurerm_logic_app_workflow.telegram.access_endpoint 
}

output "customConnector_connector_id" {
  value = azurerm_template_deployment.custom_connector.outputs.connection_id
}

output "customConnector_customApi_id" {
  value = azurerm_template_deployment.custom_connector.outputs.customApi_id
}

output "customConnector_name" {
  value = azurerm_template_deployment.custom_connector.outputs.connector_name
}

output "function_app_possible_outbound_ip_addresses" {
  value = azurerm_function_app.example.possible_outbound_ip_addresses
}
*/

output "logicApp_https_url" {
  value = azurerm_template_deployment.logicapp_workflow.outputs.logicAppUrl
}


