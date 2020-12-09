variable "prefix"                           {}
variable "location"                         {}
variable "resource_group_name"              {}

variable "function_zip_path"                {
  default = "function-telegram-proxy.zip"
}
variable "customapi_template_path"          {
  default = "custom_connector_telegram.json"
}
variable "customapi_logo_path"              {
  default = "telegram_icon.png"
}
variable "customapi_name"                   {
  default = "customapi-telegram"
}

variable "logicapp_workflow_template_path"  {
  default = "logicapp_workflow_telegram.json"
}

variable "telegram_chat_id"                 {}
variable "telegram_api_key"                 {}

