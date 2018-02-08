param
(
    [Parameter(Mandatory)]
    [String]$ComputerName,

	[Parameter(Mandatory)]
    [String]$SqlSvcPassword
)

Write-Host "The StratexSQLConfig file is being executed. The parameters are: ComputerName: $ComputerName, SqlSvcPassword: ####";
Write-Verbose -Message "The StratexSQLConfig file is being executed. The parameters are: ComputerName: $ComputerName, SqlSvcPassword: ####";

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
# Connect to the instance using SMO
$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ComputerName
[string]$nm = $s.Name
[string]$mode = $s.Settings.LoginMode

#write-output "Instance Name: $nm"
#write-output "Login Mode: $mode"

$s.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed

# Make the changes
$s.Alter()

# Change the password for the sa Account
$s.Logins.Item('sa').ChangePassword($SqlSvcPassword)
$s.Logins.Item('sa').Alter()

restart-service -Force 'MSSQLSERVER'

Import-Module SQLPS -DisableNameChecking
#Now we will create the stratex users
$login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $ComputerName, "StratexDBOwner"
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
$login.PasswordExpirationEnabled = $false
$login.Create($SqlSvcPassword)
$login.AddToRole("sysadmin")
$login.Alter()
Write-Host("Login StratexDBOwner created successfully.")

$login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $ComputerName, "StratexDBUpdater"
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
$login.PasswordExpirationEnabled = $false
$login.Create($SqlSvcPassword)
$login.AddToRole("sysadmin")
$login.Alter()
Write-Host("Login StratexDBUpdater created successfully.")