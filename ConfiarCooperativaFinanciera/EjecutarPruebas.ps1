Import-Module Microsoft.PowerShell.Management;
Import-Module Microsoft.PowerShell.Security;
Import-Module Microsoft.PowerShell.Utility;
Import-Module Microsoft.WSMan.Management;
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8';
$PSDefaultParameterValues['*:Encoding'] = 'utf8';
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls12'|
Import-Module PSProcessa;
Import-Module Pester;
Import-Module -Name "$PSScriptRoot\CApp" -Force;
$global:Config = Import-LocalizedData -FileName 'Config.psd1' -BaseDirectory ($PSScriptRoot);
$global:ConfiarCases = Import-LocalizedData -FileName 'ConfiarCases.psd1' -BaseDirectory ($PSScriptRoot);
# Add-Type -Path "$PSScriptRoot\cApp\bin\Newtonsoft.Json.dll"
# Add-Type -Path "$PSScriptRoot\cApp\bin\JWT.dll"

# SELENIUM CONFIGURATION

#add references to the Selenium DLLs 
$WebDriverPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.dll"
#I unblock it because when you download a DLL from a remote source it is often blocked by default
Unblock-File $WebDriverPath
Add-Type -Path $WebDriverPath

$WebDriverSupportPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.Support.dll"
Unblock-File $WebDriverSupportPath
Add-Type -Path $WebDriverSupportPath



$Test = Select-Test 


if($Test){


$global:Url = $Config.UrlAspen; #URL Base Aspen. Obtiene la ruta del archivo Config
# $global:PathSignin = $Url + $Config.PathSignin #Path operacion de Signin.  Obtiene la ruta del archivo Config
# $global:PathPersonalizacion = $Config.PathPersonalizacion #Path operacion de Reexpedicion.  Obtiene la ruta del archivo Config
# $global:secret = $Config.AppSecret    #Secret es un campo de la tabla Apps de la base de datos de Aspen
# $global:PathReexpedicion = $Config.PathReexpedicion #Path operacion de Reexpedicion.  Obtiene la ruta del archivo Config
$global:ResultDataRow = New-Object System.Collections.ArrayList;
#$Reexpedicion = New-Object System.Collections.ArrayList
$global:PathReport = "$PSScriptRoot\Reportes";
$global:PathReportUnit = "$PSScriptRoot\cApp\bin\ReportUnit.exe"
# $global:PathToken = Join-Path $PSScriptRoot -ChildPath '\CApp' #Ruta donde se almacena el token


if (Test-Path -Path $PathReport ) {
}
else {
	New-Item -Path $PathReport -ItemType Directory
}

Remove-Item -Path "Reportes\*.*" -Force

$Test | ForEach-Object {
    switch ( $PSItem ) {
        'Cargue Clientes'       { Invoke-Pester .\Automatizacion_Cargue_Clientes.Tests.ps1 -OutputFile "./Reportes/Automatizacion_Cargue_Clientes.xml" -OutputFormat NUnitXml }
        'Cargue Bloqueos'       { Invoke-Pester .\Automatizacion_Cargue_Bloqueos.Tests.ps1 -OutputFile "./Reportes/Automatizacion_Cargue_Bloqueos.xml" -OutputFormat NUnitXml }
        'IVR'                   { Invoke-Pester .\Automatizacion_IVR.ps1 -OutputFile "./Reportes/Automatizacion_IVR.xml" -OutputFormat NUnitXml }
        'Tarjeta con mismo BIN' { Invoke-Pester .\Automatizacion_Tarjeta_Con_Mismo_Bin.ps1 -OutputFile "./Reportes/Automatizacion_Tarjeta_Con_Mismo_Bin.xml" -OutputFormat NUnitXml }
        'Pin Pad'               { Invoke-Pester .\Automatizacion_Pin_Pad.Tests.ps1 -OutputFile "./Reportes/Automatizacion_Pin_Pad.xml" -OutputFormat NUnitXml }
        'Realce'                { Invoke-Pester .\Automatizacion_Realce.Tests.ps1 -OutputFile "./Reportes/Automatizacion_Realce.xml" -OutputFormat NUnitXml }
    }
}
Get-Xml  
Get-Report
}