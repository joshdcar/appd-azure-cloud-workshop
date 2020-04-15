# If on a Mac run "brew cask install powershell" 
# or goto https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7 
# for more options

#Get Environment Configuration
$config = Get-Content ../../environment/config.json | ConvertFrom-Json

Write-Host ("Current Configuration:") -ForegroundColor Green
Write-Host (-join("Resource Group: ", $config.AzureResourceGroup)) -ForegroundColor Green

$resourceGroup = $config.AzureResourceGroup

# Compile & Publish the Web Site 
dotnet publish -c Release "../src/SecondChanceparts.Web/SecondChanceParts.Web.csproj"
$webPublishFolder =   "../src/SecondChanceparts.Web/bin/release/netcoreapp3.1/publish"

# Create the Web Site Deployment Package
$webPackage = "secondchanceparts.web.zip"
if(Test-path $webPackage) {Remove-item $webPackage}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($webPublishFolder, $webPackage) 

# Compile & Publish the Web API
dotnet publish -c Release "../src/SecondChanceparts.Api/SecondChanceParts.Api.csproj"
$apiPublishFolder =   "../src/SecondChanceparts.Api/bin/release/netcoreapp3.1/publish"

# Create the Web API Deployment Package
$apiPackage = "secondchanceparts.api.zip"
if(Test-path $apiPackage) {Remove-item $apiPackage}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($apiPublishFolder, $apiPackage)

$webAppName = "appd-scp-web-hhwngnuzfiway"
$apiAppName = "appd-scp-api-hhwngnuzfiway"

Write-Host ("Resources Successfully Deployed") -ForegroundColor Green
Write-Host (-join("Web App Name: ",$webAppName)) -ForegroundColor Green
Write-Host (-join("Api App name: ",$apiAppName)) -ForegroundColor Green

# Use Zip Deploy to Deploy to the Azure Web Applications
# NOTE: Occasionally these do fail so the command is included to re-run if neccesary 
Write-Host("If deployment fails re-run deployment with the following commands:") -ForegroundColor Yellow
Write-Host (-join("az webapp deployment source config-zip -g ",$resourceGroup," -n ", $webAppName, " --src ", $webPackage))
Write-Host (-join("az webapp deployment source config-zip -g ",$resourceGroup," -n ", $apiAppName, " --src ", $apiPackage))

az functionapp deployment source config-zip `
 -g $resourceGroup -n $webAppName --src $webPackage

az functionapp deployment source config-zip `
 -g $resourceGroup -n $apiAppName  --src $apiPackage

 Write-Host ("Web Application Deployment Complete") -ForegroundColor Green