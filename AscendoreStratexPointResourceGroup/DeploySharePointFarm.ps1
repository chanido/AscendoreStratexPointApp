###################### For the first time only ######################

Login-AzureRmAccount

Get-AzureRmSubscription
Set-AzureRmContext -SubscriptionId 'a8e1b1ea-cee1-40f5-8ae9-37a57ff63c4b'

###################### For the first time only ######################

############################ Resource Deployment ############################

$ResourceGroupName = "AscendoreAzureApp";
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
	Name = "AscendoreAppDeployment";
	ResourceGroup = $ResourceGroupName;
	Mode = $DeploymentMode;
	TemplateFile= "$PSScriptRoot\azuredeploy.json";
	TemplateParameterObject = @{
		domainFQDN = "ascendore.local";
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
		spPassphrase = "Time you enjoy wasting is not wasted time";
		vmDCSize = "Standard_A2_v2";#"Standard_A1_v2";
		vmSQLSize = "Standard_A2_v2";
		vmSPSize = "Standard_A4_v2";
		vmsTimeZone = "GMT Standard Time";
		dnsLabelPrefix="stratexpointapp";
	};
};

write-host "Starting the deployment" -foregroundcolor "green";
New-AzureRmResourceGroupDeployment @DeploymentParameters -Force;
write-host "Deployment finished" -foregroundcolor "blue";

############################ Resource Deployment ############################

############################ OTHER TESTS ############################
Get-AzureRmVM
Get-AzureRmVMUsage -Location northeurope
Get-AzureRmVMUsage -Location uksouth

Get-AzureRmResourceGroup

Get-TimeZone -ListAvailable

############################ OTHER TESTS ############################