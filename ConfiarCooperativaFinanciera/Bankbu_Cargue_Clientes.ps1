$PathEvidencias = Join-Path $PSScriptRoot -ChildPath '\Evidencias\ConsultaMovimientos' #Ruta donde se almacenan las evidencias
$PathLoadLocks = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadI\*' #Ruta donde se almacenan las evidencias
if (Test-Path -Path $PathEvidencias ) {
}
else {
    New-Item -Path $PathEvidencias -ItemType Directory
}

#add references to the Selenium DLLs 
$WebDriverPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.dll"
#I unblock it because when you download a DLL from a remote source it is often blocked by default
Unblock-File $WebDriverPath
Add-Type -Path $WebDriverPath

$WebDriverSupportPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.Support.dll"
Unblock-File $WebDriverSupportPath
Add-Type -Path $WebDriverSupportPath

# To start a Chrome Driver
$Driver = Start-SeChrome

Set-Login -Driver $Driver

