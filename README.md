# Deploying HTTP webhook API with Logic App and Azure Telegram Connector with Terraform

Azure Monitor supports "Webhook" action type to send alert to specified webhook URL. For example, Slack webhook URL can be added to to a "Webhook" action group to send Azure alerts to slack users. 

However, Telegram is not 

- Azure Template format for Microsoft.Web/customApis and Microsoft.Web/connections
https://docs.microsoft.com/en-us/azure/templates/microsoft.web/customapis#ApiResourceDefinitions
https://docs.microsoft.com/en-us/azure/templates/microsoft.web/connections

- Create a custom connector for Logic Apps
https://docs.microsoft.com/en-us/connectors/custom-connectors/create-logic-apps-connector
https://docs.microsoft.com/en-us/connectors/custom-connectors/define-blank
https://mikaelsand.se/2020/11/how-to-use-logic-apps-custom-connectors-with-arm-and-ci-cd/

- Azure Function CI/CD
https://docs.microsoft.com/en-us/azure/azure-functions/functions-continuous-deployment
https://adrianhall.github.io/typescript/2019/10/23/terraform-functions/

- Azure Function Proxies
https://docs.microsoft.com/en-us/azure/azure-functions/functions-proxies
https://github.com/mattchenderson/azure-functions-proxies-intro/blob/master/README.md
https://chsakell.com/2019/02/03/azure-functions-proxies-in-action/

- Logic App Deployment with ARM template
https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-workflow-definition-language
https://www.nuomiphp.com/eplan/en/136757.html

terraform "templatefile" function. reads the file at the given path and renders its content as a template using a supplied set of template variables.
https://www.terraform.io/docs/configuration/functions/templatefile.html?_ga=2.114735303.1314921877.1606987310-257165690.1602728845


