#---------------------------------------------------------------------------------------------------
# Initialize Workshop Attendee Resources
#
# This script will initialize users  
#
# The AWS CLI also introduces a new set of simple file commands for efficient file transfers
# to and from Amazon S3.
#
# For more details, please visit:
#   https://aws.amazon.com/cli/
#
# NOTE: By Default Regions are capped at 10 VCPU (Soft limit). Consider Configuration carefully
#       when setting region for attendees to not go over this cap.  Current workshop VCPU Usage
#       Includes:
#       Controller: (2)
#       Azure App Services Lab: (2)
#       Azure Extension Lab: (1)
#       Optional Utility VM (Analytics/DBAgent): (1)
#
# SUGGESTION: Consider requesting additional capacity for regions prior to workshop. Additional details
#             visit https://docs.microsoft.com/en-us/azure/azure-portal/supportability/resource-manager-core-quotas-request
#
# WARNING:  The controller image must be deployed to each region you are deploying resource groups to
#---------------------------------------------------------------------------------------------------

$domain = "appdcloud.onmicrosoft.com"
$contollerUsername = "appdamin"
$controllerPassword = "welcome1"

#Get Environment Configuration
[array]$attendees = Get-Content ./attendees.json | ConvertFrom-Json 


foreach($attendee in $attendees) {
    
    Write-Host ("Processing Attendee: $($attendee.FirstName) $($attendee.LastName)") -ForegroundColor Green

    #Create AD Account
    $userPrincipal = "$($attendee.FirstName).$($attendee.LastName)@$domain"
    $displayName = "$($attendee.FirstName) $($attendee.LastName)"
    $email = "$($attendee.email)"
    $password = "AppDR0ck$!"

    #Check if user already exists
    [array]$existingUsers = az ad user list --upn "$userPrincipal" -o tsv

    if ($existingUsers.Length -eq 0) {

        az ad user create --display-name $displayName `
                  --password $password `
                  --user-principal-name $userPrincipal `
                  --force-change-password-next-login false `
                  --only-show-errors

        Write-Host ("User Created: $userPrincipal") -ForegroundColor Green

    }
    else {
        Write-Host ("User $userPrincipal already exists.") -ForegroundColor Yellow
    }
    
    #Create Resource Group & Resource Group Tags
    $resourceGroup = "azure-workshop-$($attendee.LastName)".ToLower()
    $location = $($attendee.Region)
    az group create -n $resourceGroup -l $location --output none

    Write-Host ("Resource Group Created: $resourceGroup") -ForegroundColor Green

    $today = Get-Date -Format "MM/dd/yyyy"
    az group update -n $resourceGroup --tags "Workshop=true" "Created=$today" "OwnerEmail=$email" --output none
    Write-Host ("Resource Group Tags Added: Workshop=true, Created=$today") -ForegroundColor Green

    #Assign Permissions to Resource Group
    az role assignment create --role "Owner" --assignee $userPrincipal --resource-group $resourceGroup --output none
    Write-Host ("Owner Role Assigned to $userPrincipal") -ForegroundColor Green

    $vmname="appd-controller-vm"
    $admin="appdadmin"

    #Create Controller VM
    az vm create `
        --resource-group $resourceGroup `
        --name $vmname `
        --image "/subscriptions/d4d4c111-4d43-41b2-bb7f-a9727e5d0ffa/resourceGroups/workshop-resources/providers/Microsoft.Compute/galleries/Azure_Workshop_Images/images/Azure_Workshop_Controller_Image/versions/1.0.0" `
        --size Standard_D2s_v3 `
        --admin-username $admin  `
        --os-disk-size-gb 100 `
        --ssh-key-value "../../environment/shared/keys/AppD-Cloud-Kickstart-Azure.pub" `
        --output none

    #Get the Controller VM Public IP Address
    $controllerIpAddress = az vm show -d -g $resourceGroup -n $vmname --query publicIps -o tsv

    Write-Host ("Controller VM created at IP $controllerIpAddress") -ForegroundColor Green

    $attendeeConfig = @{
        Username = $userPrincipal
        Password = $password
        AzureResourceGroup = $resourceGroup
        ControllerIpAddress = $controllerIpAddress
        Region = $($attendee.Region)
        ControllerUsername = $contollerUsername
        ControllerPassword = $controllerPassword
        } | ConvertTo-Json | Out-File "config_$($attendee.Lastname).json"

    Write-Host ("Attendee Configuration Written (config_$($attendee.Lastname).json)") -ForegroundColor Green

}