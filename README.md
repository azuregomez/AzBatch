# File-based Batch processing with Azure Batch
<h3>Business Case:</h3>
Enterprises often have file-based, IO intensive batch processes that can move to the cloud and scale horizontally with minimum code changes. The solution must:
<ul>
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
<h3>References</h3>
Az Batch Powershell<br>
https://docs.microsoft.com/en-us/azure/batch/batch-powershell-cmdlets-get-started<br>
https://github.com/Azure/azure-powershell/tree/master/src/Batch<br/>
Batch Environment Variables<br/>
https://docs.microsoft.com/en-us/azure/batch/batch-compute-node-environment-variables
