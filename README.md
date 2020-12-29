# Deploying HTTP webhook API with Logic App and Azure Telegram Connector with Terraform



v2 implementation of this module deploys only Azure logic app workflow and a logic app custom connector for telegram.

This "aztf-telegram-connector" module created below resources in the specified resource group. 

- A Logic App workflow
- A (Logic App) Custom connector (for Telegram)
- A (Logic App) API connector which binds between the workflow and custom connector



The required input variables for this module are:

- "prefix": Prefix which will be prepended to the resource name.

- "resource_group_name": resource group name

- "location": azure region

- "telegram_chat_id": Telegram "chat_id" to which the alert will be sent

- "telegram_api_key": Telegram "api_key" to authenticate when sending message to the chat room. (bot_key)

  

When the module instance is created, the following output variable will be set.

- "logicApp_https_url": Logic App URL to which Azure Alert will be sent



Below is sample terraform code creating above resources using this "aztf-telegram-connector" module and configuring Azure Alert action group using the webhook URL from the module output.

```
# deploy aztf-telegram-connector with chat_id and api_key

module "telegram-connector" {
  source = "git://github.com/hyundonk/aztf-telegram-connector.git"

  prefix                  = "example"

  resource_group_name     = "test-rg"
  location                = "southeastasia"
  
  telegram_chat_id        = "{my-chat-id}"
  telegram_api_key        = "{my-telegram-api-key}"
}

# deploy azure monitor action group using the webhook URL output from above module
resource "azurerm_monitor_action_group" "example" {
  name                    = "my test action group"

  resource_group_name     = test-rg
  short_name              = "mytestag"

  webhook_receiver {
    name                    = "webhook to telegram"
    service_uri             = module.telegram-connector.logicApp_https_url
    use_common_alert_schema = false
  }
}

# configure alert rule with the action group above. In this example, it uses log analytics log query result to send alert with the results when the number of query result is more than 0.

resource "azurerm_monitor_scheduled_query_rules_alert" "example" {
  name                = "my alert"

  resource_group_name     = "test-rg"
  location                = "southeastasia"

  action {
    action_group           = [azurerm_monitor_action_group.example.id]
    custom_webhook_payload = "{\"alertname\":\"#alertrulename\", \"IncludeSearchResults\":true}"
  }

  data_source_id = "/subscriptions/{my-subscription-id}/resourcegroups/{log-analytics-resource-group-name}/providers/microsoft.operationalinsights/workspaces/{log-analytics-name}"
 
  description    = "Alert when total results cross threshold"
  enabled        = true

  # Count all requests with server error result code grouped into 5-minute bins
  query       = <<-QUERY
  SigninLogs
  QUERY

  severity    = 2
  frequency   = 5
  time_window = 5
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
}
```



To use Telegram, you need to create a Telegram bot and a channel which gives you a channel ID and API key. (Refer [Create a bot for Telegram - Bot Service | Microsoft Docs](https://docs.microsoft.com/en-us/azure/bot-service/bot-service-channel-connect-telegram?view=azure-bot-service-4.0) for detail)

First, create a **new Telegram bot**.

![Create new bot](https://docs.microsoft.com/en-us/azure/bot-service/media/channels/tg-stepnewbot.png?view=azure-bot-service-4.0)

Then, you can get **telegram API key** which is the token to be used with HTTP API in the screenshot below.

![Copy access token](https://docs.microsoft.com/en-us/azure/bot-service/media/channels/tg-stepbotcreated.png?view=azure-bot-service-4.0)

To get "chat_id", access below URL in a web browser with the access token in the URL. Then you can get channel ID for example "1122334455" as below result.

```
https://api.telegram.org/bot183547168:AAHB5Ne2yzV5qfOvgAAgW0DHWRG0OiQLDEg/getUpdates
```

```
{"ok":true,"result":[{"update_id":123456789,
"message":{"message_id":130,"from":{"id":1122334455,"is_bot":false,"first_name":"myName","last_name":"Kim","username":"myusename","language_code":"en"},... "date":1607524265,"text":"hi"}}]}
```

 





-----------------------------------------------------------------------------

Below describes v1 implementation which is obsolete currently.

v1 uses Azure Function proxy which requires azure storage account created. When Storage Account is used in enterprise environment, it is advised to enable storage account network firewall to block un-restricted access. Also it is advised to use Azure Policy to reject creating storage account without "deny access" configuration enabled on the storage account. When storage account is used with Azure function, enabling "deny access" prevents azure function from accessing the storage account and it require vnet integration with enabling private endpoint on the storage account which is not preferable in the enterprise environment as it allows Azure PaaS service with public endpoint is accessing customer virtual network.  v2 implementation of this module removed dependency of azure function proxy and also storage account resulting more simpler implementation. 



Azure Monitor supports "Webhook" action type to send alert to specified webhook URL. For example, Slack webhook URL can be added to to a "Webhook" action group to send Azure alerts to slack users. 

However, Azure Alert doesn't support custom JSON-based webhook whereas Telegram webhook requires custom format which requires both "chat_id" and "text" field are required as below.

```
https://api.telegram.org/bot<botKey_here>/sendMessage?text=<text_here>&chat_id=<id_here>
```



To address this issue, in this "aztf-telegram-connector" terraform module, Azure Logic App and Azure Function is used to convert Azure Alert webhook format to custom webhook format that Telegram requires. This module creates a Azure Logic App workflow to provide webhook URL. The Logic App workflow then calls Azure Function Proxy which converts the webhook call from Azure Monitor Alert to the webhook format that Telegram supports. The overall diagram is as below.

 ![img](https://documents.lucid.app/documents/6037081b-26b2-46a5-883d-79939c763204/pages/0_0?a=208&x=113&y=155&w=1034&h=330&store=1&accept=image%2F*&auth=LCA%20d784ec19b10a4f574abc3eba9004ac099015f67c-ts%3D1607512170)



v1 creates the following additional resources compared with v2 implementation.

- An App Service Plan for Azure Function (consumption model)
- A Function App with proxies.json to provide proxy functionality without any custom function code
- A storage account that the function app package will be uploaded. This function app package will be used to deploy the function app.



References]

https://www.re-mark-able.net/sending-telegram-messages-azure-function-proxy-and-logic-app/

https://core.telegram.org/bots/api

https://acidpop.tistory.com/216

https://docs.microsoft.com/en-us/azure/templates/microsoft.web/customapis#ApiResourceDefinitions

https://docs.microsoft.com/en-us/azure/templates/microsoft.web/connections

https://docs.microsoft.com/en-us/connectors/custom-connectors/create-logic-apps-connector

https://mikaelsand.se/2020/11/how-to-use-logic-apps-custom-connectors-with-arm-and-ci-cd/

https://medium.com/@bappertdennis/deploy-azure-functions-with-terraform-83ab88c8373c

https://docs.microsoft.com/en-us/azure/azure-functions/functions-proxies

https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-workflow-definition-language

https://docs.microsoft.com/en-us/azure/logic-apps/monitor-logic-apps#review-trigger-history



