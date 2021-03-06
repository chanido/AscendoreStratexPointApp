param
(
    [Parameter(Mandatory)]
    [String]$ComputerName,

	[Parameter(Mandatory)]
    [String]$SqlSvcPassword
)

$Instance = 'MSSQLSERVER'

if ($Instance -ne 'MSSQLSERVER')
{
	$ServerInstance = "$ComputerName\$Instance"
}
else
{
	$ServerInstance = $ComputerName
}

Add-Content c:\stratexlog.txt "The Stratex Log file has been initialised"
Add-Content c:\stratexlog.txt "The StratexSQLConfig file is being executed. The parameters are: ComputerName: $ComputerName, SqlSvcPassword: #### => Instance: $ServerInstance"

restart-service -Force $Instance
Add-Content c:\stratexlog.txt "Server Restarted"

Add-Content c:\stratexlog.txt "Waiting 60 seconds..."
#Start-Sleep -Seconds 60
Add-Content c:\stratexlog.txt "Waited 60 seconds..."

#Write-Host "The StratexSQLConfig file is being executed. The parameters are: ComputerName: $ComputerName, SqlSvcPassword: ####";
#Write-Verbose -Message "The StratexSQLConfig file is being executed. The parameters are: ComputerName: $ComputerName, SqlSvcPassword: ####";

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
# Connect to the instance using SMO
$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ServerInstance
[string]$nm = $s.Name
[string]$mode = $s.Settings.LoginMode

Add-Content c:\stratexlog.txt "Instance Name: $nm"
Add-Content c:\stratexlog.txt "Instance Mode: $mode"
#write-output "Instance Name: $nm"
#write-output "Login Mode: $mode"

$s.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed

# Make the changes
$s.Alter()

$mode = $s.Settings.LoginMode
Add-Content c:\stratexlog.txt "Instance Mode after change: $mode"

# Change the password for the sa Account
$s.Logins.Item('sa').ChangePassword($SqlSvcPassword)
$s.Logins.Item('sa').Alter()
Add-Content c:\stratexlog.txt "Password changed for SA"

restart-service -Force $Instance
Add-Content c:\stratexlog.txt "Server Restarted"

Import-Module SQLPS -DisableNameChecking
#Now we will create the stratex users
$login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList "$ServerInstance", "StratexDBOwner"
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
$login.PasswordExpirationEnabled = $false
$login.Create($SqlSvcPassword)
$login.AddToRole("sysadmin")
$login.Alter()
Add-Content c:\stratexlog.txt "Login StratexDBOwner created successfully."

$login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList "$ServerInstance", "StratexDBUpdater"
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
$login.PasswordExpirationEnabled = $false
$login.Create($SqlSvcPassword)
$login.AddToRole("sysadmin")
$login.Alter()
Add-Content c:\stratexlog.txt "Login StratexDBUpdater created successfully."

restart-service -Force $Instance
Add-Content c:\stratexlog.txt "Server Restarted"