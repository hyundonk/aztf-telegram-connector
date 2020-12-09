# Deploying HTTP webhook API with Logic App and Azure Telegram Connector with Terraform

Azure Monitor supports "Webhook" action type to send alert to specified webhook URL. For example, Slack webhook URL can be added to to a "Webhook" action group to send Azure alerts to slack users. 

However, Azure Alert doesn't support Telegram webhook format. Azure Alert webhook doesn't support custom JSON-based webhook whereas Telegram webhook requires custom format which requires both "chat_id" and "text" field are required as below.

```
https://api.telegram.org/bot<botKey_here>/sendMessage?text=<text_here>&chat_id=<id_here>
```

In "aztf-telegram-connector" terraform module, it creates a Azure Logic App workflow to provide webhook URL. The Logic App workflow then calls Azure Function Proxy which converts the webhook call from Azure Monitor Alert to the webhook format that Telegram supports. The overall diagram is as below.







- Telegram Logic App Connector
https://github.com/foppenm/TelegramLogicAppConnector
https://www.re-mark-able.net/sending-telegram-messages-azure-function-proxy-and-logic-app/
https://core.telegram.org/bots/api
https://medium.com/@sean_bradley/get-telegram-chat-id-80b575520659
https://acidpop.tistory.com/216
https://acidpop.tistory.com/284
https://wk0.medium.com/send-and-receive-messages-with-the-telegram-api-17de9102ab78


- Azure Template format for Microsoft.Web/customApis and Microsoft.Web/connections
https://docs.microsoft.com/en-us/azure/templates/microsoft.web/customapis#ApiResourceDefinitions
https://docs.microsoft.com/en-us/azure/templates/microsoft.web/connections

- Create a custom connector for Logic Apps
https://docs.microsoft.com/en-us/connectors/custom-connectors/create-logic-apps-connector
https://docs.microsoft.com/en-us/connectors/custom-connectors/define-blank
https://mikaelsand.se/2020/11/how-to-use-logic-apps-custom-connectors-with-arm-and-ci-cd/
https://social.msdn.microsoft.com/Forums/en-US/016d8890-b7cc-408f-983c-b942cbc613ef/how-to-deploy-logic-app-custom-connector?forum=azurelogicapps

- Azure Function CI/CD
https://docs.microsoft.com/en-us/azure/azure-functions/functions-continuous-deployment
https://adrianhall.github.io/typescript/2019/10/23/terraform-functions/
https://docs.microsoft.com/en-us/azure/azure-functions/deployment-zip-push
https://medium.com/@bappertdennis/deploy-azure-functions-with-terraform-83ab88c8373c

- Azure Function Proxies
https://docs.microsoft.com/en-us/azure/azure-functions/functions-proxies
https://github.com/mattchenderson/azure-functions-proxies-intro/blob/master/README.md
https://chsakell.com/2019/02/03/azure-functions-proxies-in-action/
https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings

- Logic App Deployment with ARM template
https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-workflow-definition-language
https://www.nuomiphp.com/eplan/en/136757.html
https://yourazurecoach.com/2018/03/15/get-request-url-after-logic-apps-deployment/
https://mindbyte.nl/2019/02/13/Retrieve-the-callback-url-of-a-logic-app-inside-your-ARM-template.html

terraform "templatefile" function. reads the file at the given path and renders its content as a template using a supplied set of template variables.
https://www.terraform.io/docs/configuration/functions/templatefile.html?_ga=2.114735303.1314921877.1606987310-257165690.1602728845

Azure Alert
https://docs.microsoft.com/en-us/azure/logic-apps/monitor-logic-apps#review-trigger-history



