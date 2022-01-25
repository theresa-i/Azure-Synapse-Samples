#Requires -Modules Az.Synapse, Az.Accounts
<#
Purpose:Demonstrate how to import and export artifacts to & from Synapse Workspace

Notes:  Cmdlets used for export & import are in az.synapse module
        az.synapse doc: https://docs.microsoft.com/en-us/powershell/module/az.synapse/?view=azps-7.1.0#synapse-analytics

        How to find cmdlets needed to customize script:
        Search above URL for:
        Get-AzSynapse[artifactName]      - enumerates artifact types
        Set-AzSynapse[artifactName]      - import to storage from workspace.  set is an alias for import.  
        Export-AzSynapse[artifactName]   - exports from workspace to storage

        Export cmdlets are currently (Jan 2022) available for only:  KqlScripts, Notebooks, SparkConfiguration, SqlScript 
        Check what's available by going to doc above & search for 'Export-AzSynapse'

        How to export other artifacts not included in PowerShell module:
        Develop script using Microsoft SDK's: .NET, Java, Node, Python, or Scala.
        
        To test this script, set up the following: Synapase Workspace, 2 notebooks, 2 scripts 
        
        This is a sample script, intended to be tested and modified to accomodate your needs.  Do not run this script in production.  Test before using.  
        Modify the script to meet your needs.

        Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
        THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
        INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. We grant You a 
        nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the 
        Sample Code, provided that. You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the 
        Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; 
        and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ 
        fees, that arise or result from the use or distribution of the Sample Code  
#>

#prompt for the workspace name to backup artifacts from when running script from command line
Param(
    [Parameter()]
    [string] 
    $WorkspaceName = 'testworkspace3344',

    [Parameter()]
    [string] 
    $SubscriptionName = 'Subscription 1 - Microsoft Azure Sponsorship 2'

)

Set-StrictMode -Version Latest

#$VerbosePreference = 'continue'

#connect to Azure. *note: by default, this will kick off interactive logon via a browser
Connect-AzAccount

#set the subscription to work in
Select-AzSubscription -Subscription $SubscriptionName 

<#########################################
Enumerate Artifacts - Optional
#########################################>
#notebooks
Get-AzSynapseNotebook -WorkspaceName  $WorkspaceName | Format-Table -Property Name

#sql scripts
Get-AzSynapseSqlScript -WorkspaceName $WorkspaceName | Format-Table -Property Name

#for demo purpose only.  delete notebook and sql script files from local directory if previously imported. note current working directory is assumed
Remove-Item *.ipynb -Recurse
Remove-Item *.sql -Recurse

<#########################################
Export Artifacts
#########################################>
#notebooks
#export all notebooks from Synapse Workspaceto the same location where this script is stored locally
Get-AzSynapseNotebook -WorkspaceName  $Workspacename | Export-AzSynapseNotebook -OutputFolder .

#sql scripts
#export all sql scripts from the workspace to local storage--the same directory where this script is stored locally
Get-AzSynapseSqlScript -workspaceName $Workspacename | Export-AzSynapseSqlScript -OutputFolder .

<#######################################
Simulate disaster!  (for demo only)
Delete notebooks and sql scripts 
########################################>
#notebooks
$notebooks = Get-AzSynapseNotebook -WorkspaceName  $workspacename 
foreach ($notebook in $notebooks) {
    Remove-AzSynapseNotebook -WorkspaceName $WorkspaceName -Name $notebook.Name -Force  
}

#sqlscripts
$sqlscripts = Get-AzSynapseSqlScript -workspaceName $workspacename
foreach ($sqlscript in $sqlscripts) {
    Remove-AzSynapseSqlScript -WorkspaceName $WorkspaceName -Name $sqlscript.Name -Force  
}

<#########################################
Import Artifacts 
#########################################>
#notebooks
#note: 'set' is an alias for import so we're importing using the 'Set-AzSynapseNotebook'
#import all notebooks from same location where this script is stored locally into Synapse Workspace
$notebooks = Get-ChildItem -Path *.ipynb | Select-Object -ExpandProperty FullName
foreach ($notebook in $notebooks) {
    Set-AzSynapseNotebook -DefinitionFile $notebook -WorkspaceName $workspacename 
}

#sql scripts
#import all sql scripts from local storage to the workspace
$sqlscripts = Get-ChildItem -Path *.sql | Select-Object -ExpandProperty FullName
foreach ($sqlscript in $sqlscripts) {
    Set-AzSynapseSqlScript -DefinitionFile $sqlscript -WorkspaceName $workspacename 
}




