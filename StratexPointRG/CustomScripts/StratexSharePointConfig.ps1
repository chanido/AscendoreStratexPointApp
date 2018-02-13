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

    [String] $SPTrustedSitesName = "spsites",

	[String] $SolutionFileName = "StratexPoint-2016.wsp"
)

Add-PSSnapin Microsoft.SharePoint.PowerShell;


Add-Content c:\stratexlog.txt "The StratexSharePointConfig file is being executed. The parameters are: SQLName: $SQLName, DomainFQDN: $DomainFQDN, SqlSvcPassword: ####, SPFarmUserName: $SPFarmUserName";

###################### WE DECLARE THE FUNCTIONS FIRST ######################
$deploymentsCounter = 0;
function DeployStratexWSP
{
	$deploymentsCounter++;

	if ($deploymentsCounter -le 3)
	{
		Add-Content c:\stratexlog.txt "Trying to deploy the solution try#$deploymentsCounter";

		try
		{
            Install-SPSolution -Identity $SolutionFileName -GACDeployment -AllWebApplications -Force

            $JobName = "*solution-deployment*$SolutionFileName*"
			$job = Get-SPTimerJob | ?{ $_.Name -like $JobName }

            if ($job -eq $null) 
			{
			  Add-Content c:\stratexlog.txt "Timer job not found for $SolutionFileName"
			}
			else
			{
			  $JobFullName = $job.Name
			  Add-Content c:\stratexlog.txt  "c:\stratexlog.txt Waiting to finish job $JobFullName"
			  
			  Add-Content c:\stratexlog.txt  "c:\stratexlog.txt Waiting for $JobFullName to finish"
			  while ((Get-SPTimerJob $JobFullName) -ne $null) 
			  {
			    Add-Content c:\stratexlog.txt "."
			    Start-Sleep -Seconds 10
			  }
			  Add-Content c:\stratexlog.txt "Finished"
			}
		}
		catch 
		{
			Add-Content c:\stratexlog.txt '$SolutionFileName deployment failed, we will wait 120secs and try to do it again'
			Add-Content c:\stratexlog.txt $_.Exception.Message
			Start-Sleep -Seconds 120
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

	Add-Content c:\stratexlog.txt "Configuring web properties..."

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

	Add-Content c:\stratexlog.txt "Web properties configured"
}

function CreateStratexRootSite
{
    if ([bool] (Get-SPSite "http://$SPTrustedSitesName/" -ErrorAction SilentlyContinue) -eq $true) {
        Add-Content c:\stratexlog.txt "The root site was already present, we will delete it!"
        Remove-SPSite -Identity "http://$SPTrustedSitesName/" -Confirm:$False
    } 

	Add-Content c:\stratexlog.txt "Creating root site..."
	#$w = Get-SPWebApplication "http://$SPTrustedSitesName/"
    $template = Get-SPWebTemplate "StratexSiteDefinition#0"

	New-SPSite -Url "http://$SPTrustedSitesName/" -OwnerAlias "i:0#.w|$DomainNetbiosName\$SPFarmUserName" -Name "StratexPoint RBPM" -Template $template
	Add-Content c:\stratexlog.txt "Root site created"
}

function ResetOWSTIMER
{
	Add-Content c:\stratexlog.txt "Resetting OWSTIMER"
    $farm = Get-SPFarm
	$farm.TimerService.Instances | foreach { $_.Stop(); $_.Start(); }
	Add-Content c:\stratexlog.txt "OWSTIMER reset"
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
	CreateStratexRootSite

	#Get-SPAlternateURL "$SPTrustedSitesName" | Set-SPAlternateURL “https://mysite.local”

######################## THEN WE EXECUTE THE SCRIPTS #######################

