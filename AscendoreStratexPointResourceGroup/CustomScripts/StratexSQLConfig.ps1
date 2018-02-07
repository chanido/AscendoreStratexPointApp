param
(
    [Parameter(Mandatory)]
    [String]$ComputerName,

	[Parameter(Mandatory)]
    [SecureString]$SqlSvcPassword
)

Write-Host "The StratexSQLConfig file is being executed. The parameters are: ComputerName: $ComputerName, SqlSvcPassword: ####";
Write-Verbose -Message "The StratexSQLConfig file is being executed. The parameters are: ComputerName: $ComputerName, SqlSvcPassword: ####";

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
# Connect to the instance using SMO
$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ComputerName
[string]$nm = $s.Name
[string]$mode = $s.Settings.LoginMode

write-output "Instance Name: $nm"
write-output "Login Mode: $mode"

$s.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed

# Make the changes
$s.Alter()

# Change the password for the sa Account
$s.Logins.Item('sa').ChangePassword($SqlSvcPassword)
$s.Logins.Item('sa').Alter()

restart-service -Force 'MSSQLSERVER'