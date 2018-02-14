# AzureRM template for SharePoint 2016 configured with ADFS and StratexPoint 2016

## Description

Based on https://azure.microsoft.com/en-us/resources/templates/sharepoint-adfs/ this template deploys 3 new Azure VMs, each with its own public IP address and subnet:

* A new AD Domain Controller with a root certificate authority (AD CS) and AD FS configured
* A SQL Server 2016
* A single server running a SharePoint 2016 farm configured with 1 web application and 2 zones. Default zone is using Windows authentication and Intranet zone is using federated authentication with ADFS. Latest version of claims provider [LDAPCP](http://ldapcp.com/) is installed and configured. Some service applications and site collections are also provisionned.
* A root site with StratexPoint 2016 installed, configured and ready to be used

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

With the default sizes of virtual machines, provisioning of the template takes about 2h - 2h15 to complete.

## Known issues or limitations

### On SQL VM

* The Custom Powershell scripts I have created to change the SQL Server authentication to mixed seem to execute correctly and leave the expected traces in a log file at c:\stratexlog.txt but the changes are not applied!
* When you execute the powershell from the command line with the same parameters the server gets configured perfectly.

