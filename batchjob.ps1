# Local path where the solution files are saved
$path = "C:\projects\github\azbatchazfiles\azbatchazfiles\"
$paramfile = $path + "batchjob.parameters.json"
$params = get-content $paramfile | ConvertFrom-Json
$prefix = $params.deploymentPrefix
$accountname = $prefix + "batch"
$poolname = $params.poolname
$jobid = $params.jobid
# Get Batch context
$context = Get-AzBatchAccount -AccountName $accountname
# Create Jobs
$PoolInformation = New-Object -TypeName "Microsoft.Azure.Commands.Batch.Models.PSPoolInformation" 
$PoolInformation.PoolId = $poolname
# -- job may have -JobPreparationTask
New-AzBatchJob -Id $jobid  -PoolInformation $PoolInformation -BatchContext $context -UsesTaskDependencies
# Create Tasks
$alltasks = $params.tasks
$alltasks | ForEach-Object {    
    $task = New-Object Microsoft.Azure.Commands.Batch.Models.PSCloudTask($_.id, $_.command)
    # with dependencies, if any
    if($null -ne $_.dependencies -and $_.dependencies.lenght -gt 0){
        $dependencies = [string[]]@()
        $_.dependencies | ForEach-Object {
            $dependencies += $_.id
        }
        $task.DependsOn = New-Object Microsoft.Azure.Commands.Batch.Models.PSTaskDependencies($dependencies,$null)
    }
    New-AzBatchTask -JobId $jobid -Tasks @($task) -BatchContext $context
}
Write-Output "Job with Tasks Submitted"

