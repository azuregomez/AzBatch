# Local path where the pool solution files are saved
$path = "C:\projects\github\azbatch\"
$paramfile = $path + "batchpool.parameters.json"
$params = get-content $paramfile | ConvertFrom-Json
$prefix = $params.deploymentPrefix
$vmsku = $params.vmsku
$poolnodes = $params.poolnodes
$subscriptionid = $params.subscriptionId
$poolname = $params.poolname
$uploadapps = $params.uploadApplications
# Variables from naming conventions, could be parameters if desired
$accountname = $prefix + "batch"
$rgname = $prefix + "-rg"
$vnetname = $prefix + "-vnet"
$subnetname = $prefix + "-batch-subnet"
# Deploying Application Packages
#   #   to Publish .net core app
#   #   dotnet publish -r linux-x64
$applications = $params.Applications
# Uploading apps to the batch account only if parameter is true.  When creating a pool in a batch account that already has the apps, the param = false
if($true -eq $uploadapps){
    $applications | ForEach-Object {
        New-AzBatchApplicationPackage -AccountName $accountname -ResourceGroupName $rgname -ApplicationId $_.name -ApplicationVersion $_.version -FilePath $_.filepath -Format "zip"
    }
}
Write-Host "Applications Ready in Batch Account"
# Get Batch context
$context = Get-AzBatchAccount -AccountName $accountname
# Create Batch Pool
# -- with vanilla image, Ubuntu
$imageReference = New-Object -TypeName "Microsoft.Azure.Commands.Batch.Models.PSImageReference" -ArgumentList @("UbuntuServer","Canonical","18.04-LTS")
$configuration = New-Object -TypeName "Microsoft.Azure.Commands.Batch.Models.PSVirtualMachineConfiguration" -ArgumentList @($imageReference, "batch.node.ubuntu 18.04")
# -- deployed to a Virtual Network
$networkConfig = New-Object Microsoft.Azure.Commands.Batch.Models.PSNetworkConfiguration
$networkConfig.SubnetId = "/subscriptions/" + $subscriptionid + "/resourceGroups/" + $rgname + "/providers/Microsoft.Network/virtualNetworks/" + $vnetname + "/subnets/" + $subnetname 
# -- with Applications deployed in the nodes
[Microsoft.Azure.Commands.Batch.Models.PSApplicationPackageReference[]]$appRefs = @()
$applications | ForEach-Object {
    $appPackageReference = New-Object Microsoft.Azure.Commands.Batch.Models.PSApplicationPackageReference
    $appPackageReference.ApplicationId = $_.name
    $appPackageReference.Version = $_.version
    $appRefs += $appPackageReference
}
# -- create start task: mount file share
$filesharedir = $params.filesharedir
$azfileshareurl = $params.azfileshareurl
$account = $params.storageaccount
$accountKey = $params.accountkey
# -- mountoptions is some secret sauce hard to find: https://docs.microsoft.com/en-us/azure/batch/virtual-file-mount#examples
$mountoptions = "-o vers=3.0,dir_mode=0777,file_mode=0777,sec=ntlmssp"
$afsconfig = New-Object Microsoft.Azure.Commands.Batch.Models.PSAzureFileShareConfiguration($account, $azfileshareurl,$filesharedir,$accountKey,$mountoptions)
[Microsoft.Azure.Commands.Batch.Models.PSMountConfiguration[]]$mountConfigs = @()
$mountConfigs += $afsconfig
#$stask = New-Object Microsoft.Azure.Commands.Batch.Models.PSStartTask($command)
# -- Create batch pool 
New-AzBatchPool -Id $poolname -VirtualMachineSize $vmsku -VirtualMachineConfiguration $configuration -TargetDedicatedComputeNodes $poolnodes -NetworkConfiguration $networkConfig -BatchContext $Context -ApplicationPackageReferences $appRefs -MountConfiguration $mountConfigs
Get-AzBatchPool -BatchContext $context
