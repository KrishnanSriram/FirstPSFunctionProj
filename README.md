## Azure Powershell function - Eventgrid

Create a Azure function that will be triggered by event grid. This function accepts the parameter and prints the value.
We'll add decision making capabilities and communication with remote service next.

Following steps will help you setup resourcegroup, storage, container, event grid and function subscription

### Azure Powershell Function for storage container - Command line ARM template

#### Create a resource group

```
export resourceGroup=autosys100-rg
export location="eastus"
export storageAccount=autosys100sa
export storageContainer=autosys100container
export subscription=b1a250e2-akjnasd-asdfknjasd
az group create --name $resourceGroup --location $location
```

#### Create a storage account in the same resource group

```
az storage account create --name $storageAccount --location $location --resource-group $resourceGroup --sku Standard_LRS --kind BlobStorage --access-tier Hot
```

#### HTTP event grid tracker for events

```
az deployment group create --resource-group $resourceGroup --template-uri "https://raw.githubusercontent.com/Azure-Samples/azure-event-grid-viewer/master/azuredeploy.json" --parameters siteName=autosys100saConnection hostingPlanName=viewerhost
```

#### Create event grid

```
az provider register --namespace Microsoft.EventGrid
az provider show --namespace Microsoft.EventGrid --query "registrationState"

export storageid=$(az storage account show --name $storageAccount --resource-group $resourceGroup --query id --output tsv)
export endpoint=https://autosys100saConnection.azurewebsites.net/api/updates
```

#### Cretae HTTP Eventgrid subscription for storage container

```
az eventgrid event-subscription create --source-resource-id $storageid --name autosys100-es --endpoint $endpoint
```

Head over to visit website for events - https://autosys100saConnection.azurewebsites.net

#### create a container in storage for people to add/remove files

```
export AZURE_STORAGE_KEY="$(az storage account keys list --account-name $storageAccount --resource-group $resourceGroup --query "[0].value" --output tsv)"

az storage container create --name $storageContainer
```

#### try upload/delete files and track events in HTTP endpoint

```
touch sample.txt
az storage blob upload --file sample.txt --container-name $storageContainer --name sample.txt
az storage blob delete --container-name $storageContainer --name sample.txt
```

#### Create function app

```
az account set -s $subscription

export tag="create-function-app-connect-to-storage-account"
export storage="autosys100fn"
export functionApp="FirstFunctionProj"
export skuStorage="Standard_LRS"
export functionsVersion="4"

az storage account create --name $storage --location "$location" --resource-group $resourceGroup --sku $skuStorage

az functionapp create --name $functionApp --resource-group $resourceGroup --storage-account $storage --consumption-plan-location "$location" --functions-version $functionsVersion
```

#### Get the storage account connection string.

```
export connstr=$(az storage account show-connection-string --name $storage --resource-group $resourceGroup --query connectionString --output tsv)
```

#### Update function app settings to connect to the storage account.

```
az functionapp config appsettings set --name $functionApp --resource-group $resourceGroup --settings StorageConStr=$connstr
```

### Azure function creation

#### Init function

```
func init FirstPSFunctionProj --powershell
cd FirstPSFunctionProj
```

#### Create a HTTP trigger function

Command to create a HTTP trigger function

```
func new --name HttpExample --template "HTTP trigger" --authlevel "anonymous"
```

#### Create EventGrid trigger function

Command to create a Eventgrid trigger function

```
func new --name egExample --template "Azure Event Grid trigger"
```

#### Publish your function

When you done with your code changes, you can publish your code with the following command

```
func azure functionapp publish FirstFunctionProj
```

#### Trace your function for execution

After we successfully publish the function we can trace the execution of function with the following command

```
func azure functionapp logstream FirstFunctionProj
```

#### Associate your function with eventgrid a.k.a event subscription to function

It's very important to connect event grid with azure function, the following command will set it up

```
az eventgrid event-subscription create --name fn-invoke-1 \
 --source-resource-id /subscriptions/$subscription/resourceGroups/autosys100-rg/providers/Microsoft.Storage/storageAccounts/autosys100sa \
 --endpoint /subscriptions/$subscription/resourceGroups/autosys100-rg/providers/Microsoft.Web/sites/FirstFunctionProj/functions/egExample --endpoint-type azurefunction
```

## Execute a script in VM

### Create VM

### Enable a port, if needed

### Invoke a script from Azure function

## Next

What if we want to do the same functionality on a VM that is in a specific VNET, stay tuned
