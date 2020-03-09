# File-based Batch processing with Azure Batch
<h3>Business Case:</h3>
Enterprises often have file-based, IO intensive batch processes that can move to the cloud and scale horizontally with minimum code changes. The solution must:
<ul>
<li>Be able to run bash scripts and Linux applications
<li>Scale Horizontally to meet performance requirements
<li>Support task dependencies
<li>Have high IOPS with an SMB-based File System that is shared between all the batch worker nodes.
</ul>
<h3>Solution Architecture</h3>
<ul>
<li>To meet scalability and performance requirements and support task dependency, we will use Azure Batch:<br>
https://docs.microsoft.com/en-us/azure/batch/<br/>
https://docs.microsoft.com/en-us/azure/batch/batch-task-dependencies<br/>
<li>To meet high IOPS and a shared file system, we will use Azure Files on Premium Storage: <br/>
https://azure.microsoft.com/en-us/blog/premium-files-redefines-limits-for-azure-files/
<li>Azure Batch supports Application Packages, a mechanism to upload and manage applications (executables, scripts) and versions.<br/>
https://docs.microsoft.com/en-us/azure/batch/batch-application-packages
<li>Pre-requisites: Azure Subscription, Azure Batch Explorer https://azure.github.io/BatchExplorer/
</ul>
<img src="https://storagegomez.blob.core.windows.net/public/images/azbatchazfiles.jpg"/>
<h3>Solution Steps</h3>
<img src="https://storagegomez.blob.core.windows.net/public/images/azbatchsteps.jpg"/>
<table>
<tr>
<th>Step</th>
<th>Files</th>
<th>Description</th>
</tr>
<tr>
<td>1</td>
<td>azuredeploy.json<br>
azuredeploy.parameters.json
</td>
<td>ARM Template that deploys Azure Resources: Azure Batch Account, Storage Account, File Share, VNet<br/>
At the end of this template, the batch files to be processed have to be copied to the Azure File Share via another process or manually through the Azure Portal.  This other process can be automated and FTP can be part of it.  https://github.com/azuregomez/AFBlobSave</td>
</tr>
<tr>
<td>2</td>
<td>batchpool.ps1<br>
batchpool.parameters.json
</td>
<td>Powershell Script that deploys a pool of worker nodes in a VNet, and copies applications and versions specofied in the parameters file. The script also mounts the Azure File Share in all the pool nodes.<td>
</tr>
<tr>
<td>3</td>
<td>batchjob.ps1<br>
batchjob.parameters.json
</td>
<td>Powershell script that submits a job with tasks and dependencies. Teh job will be executed in the specified worker pool.  The parameter file includes tasks to be executed, which are usually invocations to applications installed in step 2.</td>
</tr>
<tr>
<td></td>
<td>sh directory
</td>
<td>Sample bash scripts to be able to run this solution as a demo.  The demo executes the same script rwfile.sh that just reads and writes a file.  The batchjob.parameters.json file has a sample parameter configuration for task dependencies.</td>
</tr>
</table>
All tasks and scripts have to take into account the task runtime environment variables:<br>
https://docs.microsoft.com/en-us/azure/batch/batch-compute-node-environment-variables
<h3>The demo</h3>
As it is provided: 
<ul>
<li>The pool parameter file creates a pool with 2 nodes. This is configurable.
<li>The job parameter file is configured to do the following tasks and dependencies:
<img src="https://storagegomez.blob.core.windows.net/public/images/tasks.jpg"/>
<li>The task script that reads and writes files is sh/rwfile.sh 
<h3>References</h3>
Az Batch Powershell<br>
https://docs.microsoft.com/en-us/azure/batch/batch-powershell-cmdlets-get-started<br>
https://github.com/Azure/azure-powershell/tree/master/src/Batch<br/>
Batch Environment Variables<br/>
https://docs.microsoft.com/en-us/azure/batch/batch-compute-node-environment-variables<br/>
High Availability and Disaster Recovery:<br>
https://docs.microsoft.com/en-us/azure/batch/high-availability-disaster-recovery
