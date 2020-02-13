Import-Module Mdbc -RequiredVersion 5.1.3 -Force
Import-Module Microsoft.PowerShell.Management
Import-Module Microsoft.PowerShell.Security
Import-Module Microsoft.PowerShell.Utility
Import-Module Microsoft.WSMan.Management
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::'Tls12'
Import-Module PSProcessa
Import-Module Pester
#Remove-Module Mdbc -Force
Import-Module -Name "$PSScriptRoot\CApp" -Force
Add-Type -Path "$PSScriptRoot\cApp\bin\Newtonsoft.Json.dll"
Add-Type -Path "$PSScriptRoot\cApp\bin\JWT.dll"
Add-Type -Path "$PSScriptRoot\cApp\bin\AE.Net.Mail.dll"

$Result = Select-Client
$Test = Select-Test -Client $Result.Cliente
$global:Client = $Result.Cliente
$global:Config = Import-LocalizedData -FileName $Client'Config.psd1' -BaseDirectory ($PSScriptRoot)
$EmailContent = Import-LocalizedData -FileName 'MensajeEmail.psd1' -BaseDirectory ($PSScriptRoot)
$Url = $Config.UrlAspen #URL Base Aspen. Obtiene la ruta del archivo Config
$global:PathSignin = $Url + $Config.PathSignin
$global:PathSolicitudToken = $Url + $Config.PathSolicitudToken #Path operacion de Consulta Saldos.  Obtiene la ruta del archivo Config
$global:PathCompra = $Url + $Config.PathCompra
$global:PathReversoCompra = $Url + $Config.PathReversoCompra
$global:PathReport = "$PSScriptRoot\Reportes"
$global:PathReportUnit = "$PSScriptRoot\cApp\bin\ReportUnit.exe"
$global:PathAnulacionCompra = $Url + $Config.PathAnulacionCompra
$global:PathReversoAnulacion = $Url + $Config.PathReversoAnulacion
$global:PathToken = Join-Path $PSScriptRoot -ChildPath '\CApp' #Ruta donde se almacena el token
Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'ActualizacionSaldos'

$Test | ForEach-Object {
    switch ( $PSItem ) {
        'Solicitud de Token' { Invoke-Pester .\SolicitudToken_Transaccional.Tests.ps1 -EnableExit -OutputFile "./Reportes/SolicitudToken.xml" -OutputFormat NUnitXml }
        'Compra' { Invoke-Pester .\Compra.Tests.ps1 -EnableExit -OutputFile "./Reportes/Compra.xml" -OutputFormat NUnitXml }
        'Reverso de Compra' { Invoke-Pester .\ReversoCompra.Tests.ps1 -EnableExit -OutputFile "./Reportes/ReversoCompra.xml" -OutputFormat NUnitXml}
        'Anulacion de Compra' { Invoke-Pester .\AnulacionCompra.Tests.ps1 -EnableExit -OutputFile "./Reportes/AnulacionCompra.xml" -OutputFormat NUnitXml }
        'Reverso Anulacion de Compra' { Invoke-Pester .\ReversoAnulacionCompra.Tests.ps1 -EnableExit -OutputFile "./Reportes/ReversoAnulacionCompra.xml" -OutputFormat NUnitXml }

    }
}
Get-Xml
Get-Report


