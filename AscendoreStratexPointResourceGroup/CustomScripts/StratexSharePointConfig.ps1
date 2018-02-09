param
(
    [Parameter(Mandatory)]
    [String]$SQLName,

	[Parameter(Mandatory)]
    [String]$DomainFQDN,

	[Parameter(Mandatory)]
    [String]$SqlSvcPassword,

    [Parameter(Mandatory)]
    [String]$SPFarmUserName,

	[Parameter(Mandatory)]
    [String] $SPTrustedSitesName,

	[String] $SolutionFileName = "StratexPoint-2016.wsp"
)

Add-PSSnapin Microsoft.SharePoint.PowerShell;


Write-Host "The StratexSharePointConfig file is being executed. The parameters are: SQLName: $SQLName, DomainFQDN: $DomainFQDN, SqlSvcPassword: ####, SPFarmUserName: $SPFarmUserName";
Write-Verbose -Message "Verbose: The StratexSharePointConfig file is being executed. The parameters are: SQLName: $SQLName, DomainFQDN: $DomainFQDN, SqlSvcPassword: ####, SPFarmUserName: $SPFarmUserName";

###################### WE DECLARE THE FUNCTIONS FIRST ######################
$deploymentsCounter = 0;
function DeployStratexWSP
{
	$deploymentsCounter++;

	if ($deploymentsCounter -le 3)
	{
		Write-Host "Trying to deploy the solution try#$deploymentsCounter";

		try
		{
			Install-SPSolution -Identity $SolutionFileName -GACDeployment -AllWebApplications -Force
			
			$JobName = "*solution-deployment*$SolutionFileName*"
			$job = Get-SPTimerJob | ?{ $_.Name -like $JobName }
			
			if ($job -eq $null) 
			{
			  Write-Host Timer job not found for $SolutionFileName
			}
			else
			{
			  $JobFullName = $job.Name
			  Write-Host -NoNewLine Waiting to finish job $JobFullName
			  
			  while ((Get-SPTimerJob $JobFullName) -ne $null) 
			  {
			    Write-Host -NoNewLine .
			    Start-Sleep -Seconds 2
			  }
			  Write-Host Finished
			}
		}
		catch 
		{
			Write-Verbose -Message '$SolutionFileName deployment failed, we will try to do it again'
			Write-Verbose -Message $_.Exception.Message
			DeployStratexWSP;
		}
	}
	else
	{
		Write-Verbose -Message 'Maximum number of retries reached trying to deploy the $SolutionFileName';
	}
}

function ConfigureStratexWSP
{
	#Write Web Properties

	$WebApp = Get-SPWebApplication "http://$SPTrustedSitesName/"
	
	[Reflection.Assembly]::"Ascendore.Utils.dll"
	
	$PathToDatebaseFile = [Ascendore.Utils.StratexConstants]::PathToDatabaseFileKey;
	$PathToDatebaseLogFile = [Ascendore.Utils.StratexConstants]::PathToDatabaseLogFileKey;
	$DBCreationStringKey = [Ascendore.Utils.StratexConstants]::DBCreationString;
	$DBUpdateStringKey = [Ascendore.Utils.StratexConstants]::DBUpdateString;
	$DBAutoConfigDisableKey = [Ascendore.Utils.StratexConstants]::DBAutoconfigDisabledKey
	
	[Ascendore.Utils.Common]::SetWebApplicationPropertyCypher($WebApp, $PathToDatebaseFile, "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA")
	[Ascendore.Utils.Common]::SetWebApplicationPropertyCypher($WebApp, $PathToDatebaseLogFile, "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA")
	
	$DBCreationValue = "Data Source=$SQLName;User ID=StratexDBOwner;Password=$SqlSvcPassword;Trusted_Connection=False;"
	$DBUpdateValue = "Data Source=$SQLName;User ID=StratexDBUpdater;Password=$SqlSvcPassword;Trusted_Connection=False;"
	
	[Ascendore.Utils.Common]::SetWebApplicationPropertyCypher($WebApp, $DBCreationStringKey, $DBCreationValue)
	[Ascendore.Utils.Common]::SetWebApplicationPropertyCypher($WebApp, $DBUpdateStringKey, $DBUpdateValue)
	
	
	[Ascendore.Utils.Common]::SetWebApplicationPropertyCypher($WebApp, $DBAutoConfigDisableKey, "false")
}

function CreateStratexRootSite
{
	$w = Get-SPWebApplication "http://$SPTrustedSitesName/"

	New-SPSite http://spsites -OwnerAlias "i:0#.w|$DomainNetbiosName\$SPFarmUserName" -HostHeaderWebApplication $w -Name "StratexPoint RBPM" -Template "StratexSiteDefinition#0"
}

function ResetOWSTIMER
{
    $farm = Get-SPFarm
	$farm.TimerService.Instances | foreach { $_.Stop(); $_.Start(); }
}

function Get-NetBIOSName
{
    [OutputType([string])]
    param(
        [string]$DomainFQDN
    )

    if ($DomainFQDN.Contains('.')) {
        $length=$DomainFQDN.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        return $DomainFQDN.Substring(0,$length)
    }
    else {
        if ($DomainFQDN.Length -gt 15) {
            return $DomainFQDN.Substring(0,15)
        }
        else {
            return $DomainFQDN
        }
    }
}

###################### WE DECLARE THE FUNCTIONS FIRST ######################

######################## THEN WE EXECUTE THE SCRIPTS #######################
[String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)

    # The deployment of the solution is made in owstimer.exe tends to fail very often, so restart the service before to mitigate this risk
	ResetOWSTIMER
	DeployStratexWSP
	ResetOWSTIMER
	ConfigureStratexWSP	   

	#Get-SPAlternateURL "$SPTrustedSitesName" | Set-SPAlternateURL “https://mysite.local”

######################## THEN WE EXECUTE THE SCRIPTS #######################

