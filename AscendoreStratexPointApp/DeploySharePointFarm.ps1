Login-AzureRmAccount

Get-AzureRmSubscription
Set-AzureRmContext -SubscriptionId 'a8e1b1ea-cee1-40f5-8ae9-37a57ff63c4b'

New-AzureRmResourceGroup -Name AscendoreAzureApp -Location 'uksouth'

Get-AzureRmResourceGroup

############################ Resource Deployment ############################

if(!$PSScriptRoot -and $MyInvocation.MyCommand.Path){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
if(!$PSScriptRoot){ $PSScriptRoot = "C:\GitHub\AscendoreStratexPointApp\AscendoreStratexPointApp\"; }

$Password = "GoodPassword!1";

$DeploymentParameters = @{
	Name = "AscendoreAppDeployment";
	ResourceGroup = "AscendoreAzureApp";
	Mode = "Complete";
	TemplateFile= "$PSScriptRoot\FarmDeploymentScript\sharepoint-three-vm\azuredeploy.json";
	TemplateParameterObject = @{
		sharepointFarmName="AscAppFarm16";
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
		spPublicIPRGName = "ascendoreazureapp";
		sppublicIPAddressName = "ascendoreappfarmip";
		storageAccountNamePrefix = "ascendoreappstorageacc";
		storageAccountType = "Standard_GRS";
	};
};
New-AzureRmResourceGroupDeployment @DeploymentParameters;

############################ Resource Deployment ############################

############################ OTHER TESTS ############################
Get-AzureRmVM
Get-AzureRmVMUsage -Location northeurope
Get-AzureRmVMUsage -Location uksouth

Remove-AzureRmResourceGroup -Name "AscendoreAzureApp"
############################ OTHER TESTS ############################