# Azure App Services

![scpFlowmap][scpFlowmap]

# App Service Overview

[Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/)s is one of the most popular PaaS (Platform as a Service) offerings on Azure and enables you to build and host web apps and APIs in the programming language of your choice and is all done without having to manage the underlying infrastracture.  

Azure App Services are made up of two key components:
* **App Service**  - Contains the web site (or API) and all of its configuration and code
* **App Service Plan**  - The underlying infrastracture that equats to the physical VMs behind the scenes. Multiple sites are permitted to be associated with a single App Service Plan allowing for higher density deployments. Similiar to a single server hosting IIS with several seperate IIS sites. There are several tiers of app service plans available that have different abilities and scaling characteristics.

AppDynamics has first class integration with Azure App Services through a feature referred to as **Site Extensions**. Site extensions allow for the deployment of configuration and files to an application deployed to Azure App Services.  In the case of AppDynamics we have the preferred option of deploying our agent through these site extensions making the agent deployment experience for Azure App Services quite simple and fairly turn key.

Azure App Services supports various languages and platforms from windows and linux to .net, php, java, and node.js.  The site extensions today only supports the deployment of the .net agent to windows. AppDynamics supports the other environments but agents must be deployed with other patterns such as CI\CD. 

> **TIP:**  Azure App Services has gone through re-branding over the years. Azure App Services, Azure Web Sites, Azure Mobile Apps, Azure API Apps are all Azure App Services. However, a legacy PaaS platform on Azure referred to as Cloud Services is still available for customers.  This is a seperate offering that AppDynamics does support but is not covered in this lab. 

## Kudu

Because Azure App Services is in a managed environment there is no access to the underlying operating system and runs within a [Sandbox](https://github.com/projectkudu/kudu/wiki/Azure-Web-App-sandbox) which comes with some restrictions on some of the processes that can be run and executed. This includes no ability to "Remote Desktop" into the servers and perform common tasks like viewing processes, logs, uploading files, etc.

![kuduHome][kuduHome]

To compensate for this each Azure App Service has a Kudu site deployed along side it. Kudu is a web based management interface where you can perform various administrative tasks (beyond the portal administration) and also provides some of the underlying functionality provided by Azure App Services such as git based deployments. Most importantly Kudu is the engine that manages and deploys **site extensions**.  

Kudu sites have a naming convention of *https://[my-site-name].scm.azurewebsites.net*. Even when a site has a custom domain it still retains the original default "azurewebsites.net" domain and scm prefix. Kudo is generally launched from the administrative pages of Azure App Services on the portal. 

**Kudu plays a very important role with AppDynamics** and provides us the interface to troubleshoot agent deployments and access to agent logs. 

[TODO - KUDU Image]

# Lab Scenerio

Second Chance parts is an online ecommerce company that that sells autoparts sources from auto junk yards. Second Chance Parts has identified Azure App Services as the service of choice because they find the fully managed platform with elastic scaling attractive. 

## Tech Stack
Second Chance Parts is historically a microsoft shop so they have chosen the following application architecture:

* .Net Core 3.1
* ASP.NET Razor Pages
* ASP.NET Web API (Rest)
* Azure SQL 

## Lab Primary Objectives

* Provision Azure App Services to support the Web UI and APIs with ARM Templates
* Provision and Azure SQL Database with ARM Templates
* Deploy the application components to Azure App Services
* Deploy, Configure, and Validation\Troubleshoot the AppDynamics Agent 

## Lab Steps

## **Step #1** - Provisioning Azure App Services and Deploying the Application 

### **Azure Resoruces Being Deployed**

The following Azure Resources will be deployed as part of this step:
  
  * Azure App Service (Web UI)
  * Azure App Service Plan (Web UI)
  * Azure App Service (API)
  * Azure App Service Plan (API)
  * Azure SQL Database

![resourceDiagram][resourceDiagram]

> *TIP:* This diagram was automatically created using the ARM Template Previewer Extension in Visual Studio Code and will automatically preview any valid ARM Template. In this case the *azure-deploy.json* located in the /labs/app-services/deploy folder of the workshop repo. 

### **Deployment Script**
The Azure App Services Lab contains a single unified powershell script found within your project under **/labs/app-services/deploy/azure-deploy.ps1** that performans the following actions:

1. Compile and packaging of the the SecondChanceParts component into a "zip" file

2. Provisioning of Azure resources from an ARM template and executed by the Azure CLI

3. Deployment of the packaged components to the Azure App Services via the Azure CLI. 


### Executing the Deployment Script

From a terminal window navigate to your workshop project folder and the **/labs/app-services/deploy** folder and execute the following command.

> **Windows**  ``` > pwsh .\azure-deploy.ps1```

> **Mac**  ``` > pwsh ./azure-deploy.ps1```

### **Expected Output**

The execution of this command should reflect something similiar to the following image. 

![deploymentOutput][deploymentOutput]

> **TIP:** If you get an errors during the execution ensure that you have correctly installed all the workshop prerequisites.  It is not uncommon to see deployment errors during the deployment. If this is the case review the output of the script for deployment commands that can be executed again.

Interested in understanding more about this script? Jump to **[EXTRA CREDIT - Better Understanding the deployment script](#understandingdeploy)** for more details!

### **Validate Azure Resource Deployment**

Validate that your azure resources are deployed by logging into the Azure Portal and opening your resource group.

![appServiceResources][appServiceResources]

### **Check your Website**

Verify that the web site is up and running by visiting it in your browser. You can find your websites URL in the portal by opening the **appd-scp-web** labeled app service resource. 

![appServiceUrl][appServiceUrl]

#### Verify the site is running. Start shopping by entering a name and selecting "Start Shopping"

![scpSite][scpSite]


## **Step #2** - Installing the AppDynamics Agent

In this step we will be installing and configuring the Appdynamics Agents through Site Extensions. **You will need the the name and access key from your controller**. 

> **TIP** Site Extensions can be deployed and configured automatically through ARM Templates. Review the ARM Template **azure-deploy-extensions.json** located within this labs deployment folder. Take special note of the site extension elements along with the appdynamics appsettings elements.  This is a true zero touch deployment mechansim that organizations using CI\CD may find attractive. 


### 1. Navigate to the Web Azure App service and select **Extensions** from the left menu (scrolling down). Then select **Add**

![extension1][extension1]

### 2. Scroll to the AppDynamics 4.5 extension. Also ensure you accept the legal terms and select **OK** 

![extension2][extension2]

### 3. Confirm the extension has been installed and select **Browse** from the dialog.

![extension3][extension4]

### 4. You should be taken to the AppDynamics Configuration Page. Enter the appropriate details and choose **Validate**

![extension4][extension5]

> **ALERT** On occasion you may get an error relating to path not found (or similiar) when accessing this site after activating the site extensions. Return to the azure portal and restart the web application and try visiting the same page again. 

### 5. As directed - restart the web application.

![extension6][extension6]

### 6. **REPEAT same steps 1-5 for the API App Service**

### 7. Generate traffic on the Second Chance Parts site and ensure you have the flowmap and BTs populating.

![scpFlowmap][scpFlowmap]

## **Step #3** - Reviewing Logs and Troubleshooting 

All files can be access from within the Kudu console by going to **Debug console -> cmd** on the main top menu.

### **AppDynamics Logs**

Logs are available from the Kudu console but not located in the typical .net agent location and instead within the app service's centralized log file location located at **D:\home\logfiles\AppDynamics**.

![kuduLog][kuduLog]

> **Tip** The storage used by Azure App Services is shared across all instances. As additional instances are added to an App Service Plan those logs are all written to the same files. In the profiler folder you will see each file seperated by process id. Those may be process ids that are coming from different instances.


### **Additional Agent Settings**

Additional agent settings, for example the AppDynamicsConfig.json can be found at **d:\home\SiteExtensions\AppDynamics.WindowsAzure.SiteExtensions.4.5.Release\AppDynamics**

![kuduAgentFiles][kuduAgentFiles]

### **Confirming Agent is Loaded**

It can be helpful to confirm that the agent is loaded into the application to determine if additional resets are required or if there are other issues preventing the agent from attaching. You can review processes and look for the AppDynamics module is loaded within the process by viewing the **Process Explorer** from the top menu.

![kuduProcesses][kuduProcesses]
![kuduProcessModules][kuduProcessModules]

<br><br><br>

# **EXTRA CREDIT** Better Understanding the Deployment Script  
<a name="understandingdeploy"></a>


[resourceDiagram]: ../../images/labs/azure_resource_diagram.png "Resource Diagram"
[deploymentOutput]: ../../images/labs/app_service_deployment.png "Deployment Output"
[appServiceResources]: ../../images/labs/app_service_resources_portal.png "appServiceResources"
[appServiceUrl]: ../../images/labs/app_service_url.png "appServiceUrl"
[scpSite]: ../../images/labs/second_chance_parts_site.png "scpSite"
[scpFlowmap]: ../../images/labs/second_chance_parts_flowmap.png "scpSite"
[extension1]: ../../images/labs/site_extensions_1.png "extension1"
[extension2]: ../../images/labs/site_extensions_2.png "extension2"
[extension3]: ../../images/labs/site_extensions_3.png "extension3"
[extension4]: ../../images/labs/site_extensions_4.png "extension4"
[extension5]: ../../images/labs/site_extensions_5.png "extension5"
[extension6]: ../../images/labs/site_extensions_6.png "extension6"
[kuduHome]: ../../images/labs/kudu_home.png "kuduHome"
[kuduLog]: ../../images/labs/kudu_log.png "kuduLog"
[kuduAgentFiles]: ../../images/labs/kudu_agent_files.png "kuduAgentFiles"
[kuduProcesses]: ../../images/labs/kudu_processes.png "kuduProcesses"
[kuduProcessModules]: ../../images/labs/kudu_process_module.png "kuduProcessModules"