# Workshop - Getting Started
**Before continueing please confirm you have installed all the [pre-requisites](prerequisites.md) for the workshop.**

## Clone This Workshop Github Repository
The Azure Cloud Workshop is maintained here on github as a git repostiory . Before starting the workshop you should clone this repository so you have it locally on your computer. ([What is cloning?](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)). 

### git command line

```
command prompt: git clone https://github.com/joshdcar/appd-azure-cloud-workshop
```

### Visual Studio Code
This can be done via git command line tools are in the example below, through Visual Studio Code.

[Insert Visual Studio Instructions]

Once cloned open the appd-azure-cloud-workshop.code-workspace file with Visual Studio Code. Confirm you see a directory structure similiar to the image below with Visual Studio Code. 

## Copy Workshop Config File

Before getting started with the lab confirm you have access to the workshop's Azure subscription with the account credentials json file provided by your workshop organizer. 

![Config File][configfile]

Please note the **Azure login credentials** (Username and password) and the **Controller details** (Controller IP Address, ControllerUsername, and ControllerPassword) as you will need to use these throughout the workshop. 

Copy the contents of the config json file into the config.json file located in the environment folder of your local cloned copy of the workshop repository.

![Config File][configLocation]

## Confirm Azure Access







#### Azure Portal


#### Azure CLI


#### Azure Powershell


## Confirm AppDynamics Controller Access


## Labs

This workshop consists of several labs with both primary, secondary , and bonus objectives.

| Lab   |      Primary Objective     |  Secondary Objective |  Bonus Objective |
|----------|:-------------|:------|:------|
| Azure App Services |  Deploying Agents via Site Extensions | Provision Resources w/ ARM Templates | Configure Analytics |
| Azure Monitor Extensions |    Configure Azure Monitor   | Provision Resources w/ Azure CLI | Monitor Multiple Resources |
| Azure Functions | Deploying Agents via Site Extensions | Provision Resources w/ Powershell | SQL & CosmosDB Metrics |
| Azure Kubernetes Services (AKS) | Deploy Cluster Agent |    kubectl with AKS |  |

[configfile]: ../images/labs/Config_File_Sample.png "Config File"
[configLocation]: ../images/labs/Config_File_Location.png "Config File Location"