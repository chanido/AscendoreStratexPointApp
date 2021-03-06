﻿###################### For the first time only ######################

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
if(!$PSScriptRoot){ $PSScriptRoot = "C:\GitHub\AscendoreStratexPointApp\AscendoreStratexPointApp\"; }
	

$Password = "GoodPassword!1";

$DeploymentParameters = @{
	Name = "AscendoreAppDeployment";
	ResourceGroup = $ResourceGroupName;
	Mode = $DeploymentMode;
	TemplateFile= "$PSScriptRoot\FarmDeploymentScript\sharepoint-three-vm\azuredeploy.json";
	TemplateParameterObject = @{
		sharepointFarmName="AscApp16";
		virtualNetworkName="ascendoreappvn";
		domainName = "ascendore.local";
		adVMSize = "Standard_DS2_v2";
		spVMSize = "Standard_DS2_v2";
		sqlVMSize = "Standard_DS3_v2";

		adminUsername ="FarmAdm";
		adminPassword =$Password;
		sqlServerServiceAccountUserName ="SqlAdm";
		sqlServerServiceAccountPassword = $Password;
		sharePointSetupUserAccountUserName = "SPSetup";
		sharePointSetupUserAccountPassword =$Password;
		sharePointFarmAccountUserName = "SPFarm";
		sharePointFarmAccountPassword =$Password;
		sharePointFarmPassphrasePassword = "Time you enjoy wasting is not wasted time";

		spDNSPrefix="ascendoreappfarm";
		spPublicIPNewOrExisting="new";
		spPublicIPRGName = $ResourceGroupName.ToLower();
		sppublicIPAddressName = "ascendoreappfarmip";
		storageAccountNamePrefix = "ascendoreappstorageacc";
		storageAccountType = "Standard_GRS";
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

############################ OTHER TESTS ############################