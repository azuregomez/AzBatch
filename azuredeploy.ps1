# template file and params copied to local
$localpath = "<your local path>"
$templatefile = $localpath + "azuredeploy.json"
$templateparamfile = $localpath + "azuredeploy.parameters.json"
# Change this location to your preferred location:
$location = "Central US"
#get prefix from parameter file
$params = get-content $templateparamfile | ConvertFrom-Json
$prefix = $params.parameters.deploymentPrefix.value
# using template naming conventions for rg, sqlserver and keyvault
$rgname = $prefix + "-rg"
$rg = get-azresourcegroup -location $location -name $rgname
if ($null -eq $rg)
{
    new-azresourcegroup -location $location -name $rgname
}
# Deploying ARM template 
New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $templateFile -TemplateParameterFile $templateparamfile 
write-host "ARM Deployment Complete"
# the outcome of deployment:
#   + App Insights instance
#   + Azure Batch Account
#   + Virtual Network for the Worker Pool 
#   + Storage Account for the batch artifacts (applications, files)
#   + Premium Storage Account with Azure File Share
get-azresource -resourcegroup $rgname
