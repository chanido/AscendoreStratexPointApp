###################### For the first time only ######################

Login-AzureRmAccount

Get-AzureRmSubscription
Set-AzureRmContext -SubscriptionId 'a8e1b1ea-cee1-40f5-8ae9-37a57ff63c4b'

###################### For the first time only ######################

############################ Resource Deployment ############################

$ResourceGroupName = "StratexPoint-AzureApp-ResourceGroup";
$DeploymentMode = "Complete"; #"Incremental"; #

if ($DeploymentMode -eq "Complete") {
	write-host "The resource group will be deleted" -foregroundcolor "red";
	Remove-AzureRmResourceGroup -Name $ResourceGroupName  -Force;
	write-host "The resource group has been deleted" -foregroundcolor "red";
	New-AzureRmResourceGroup -Name $ResourceGroupName -Location 'uksouth';
	write-host "The resource group has been created" -foregroundcolor "green";
}
else {
	write-host "The deployment is incremental..." -foregroundcolor "green";
}

if(!$PSScriptRoot -and $MyInvocation.MyCommand.Path){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
if(!$PSScriptRoot){ $PSScriptRoot = "C:\GitHub\AscendoreStratexPointApp\AscendoreStratexPointResourceGroup"; }
	

$Password = "GoodPassword!1";

$DeploymentParameters = @{
	Name = "StratexPointAppDeployment";
	ResourceGroup = $ResourceGroupName;
	Mode = $DeploymentMode;
	#TemplateFile= "$PSScriptRoot\azuredeploy.json";
	TemplateFile= "$PSScriptRoot\mainTemplate.json";
	TemplateParameterObject = @{
		domainFQDN = "stratexpoint.local";
		adminUserName = "FarmAdm";
		adminPassword = $Password;
		adfsSvcUserName = "adfssvcadm";
		adfsSvcPassword = $Password;
		sqlSvcUserName = "SqlAdm";
		sqlSvcPassword = $Password;
		spSetupUserName = "SPSetup";
		spSetupPassword = $Password;
		spFarmUserName = "SPFarm";
		spFarmPassword = $Password;
		spSvcUserName = "SPService";
		spSvcPassword = $Password;
		spAppPoolUserName = "SPApplicationPool";
		spAppPoolPassword = $Password;
		#SPPassphraseCreds = "Time you enjoy wasting is not wasted time";
		vmDCSize = "Standard_A2_v2";#"Standard_A1_v2";
		vmSQLSize = "Standard_A4_v2";
		vmSPSize = "Standard_A4_v2";
		#vmsTimeZone = "GMT Standard Time";
		dnsLabelPrefix="stratexpointapp";
	};
};

$properties = @{"AccountType"="Standard_LRS"}

write-host "Starting the deployment" -foregroundcolor "green";
New-AzureRmResourceGroupDeployment @DeploymentParameters -storageAccountType Standard_GRS -Force;
write-host "Deployment finished" -foregroundcolor "blue";

############################ Resource Deployment ############################

############################ OTHER TESTS ############################
Get-AzureRmVM
Get-AzureRmVMUsage -Location northeurope
Get-AzureRmVMUsage -Location uksouth

Get-AzureRmResourceGroup

Get-TimeZone -ListAvailable

((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Web).ResourceTypes | Where-Object ResourceTypeName -eq sites).ApiVersions

((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Network).ResourceTypes).ApiVersions
((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute).ResourceTypes | Where-Object ResourceTypeName -eq VirtualMachines).ApiVersions

((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Storage).ResourceTypes | Where-Object ResourceTypeName -eq storageAccounts).ApiVersions
((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Network).ResourceTypes | Where-Object ResourceTypeName -eq publicIPAddresses).ApiVersions

[System.TimeZoneInfo]::GetSystemTimeZones().DisplayName
[System.TimeZoneInfo]::GetSystemTimeZones().Id
[System.TimeZoneInfo]::Local.Id




############################ OTHER TESTS ############################