$PathEvidencias = Join-Path $PSScriptRoot -ChildPath '\Evidencias\ConsultaMovimientos' #Ruta donde se almacenan las evidencias
$PathLoadLocks = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadI\*' #Ruta donde se almacenan las evidencias
Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\WinSCP\5.15.9.0\lib\WinSCPnet.dll"



if (Test-Path -Path $PathEvidencias ) {
}
else {
    New-Item -Path $PathEvidencias -ItemType Directory
}

# Load WinSCP .NET assembly

# Set up session options
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
Protocol = [WinSCP.Protocol]::Sftp
HostName = $Config.SftpConnectionConfiar.Host
UserName = $Config.SftpConnectionConfiar.Username
Password = $Config.SftpConnectionConfiar.Password
SshHostKeyFingerprint = $Config.SftpConnectionConfiar.Fingerprint
}

$CreditCard = "125485478562356";

$CreditCard | Out-File ".\Reportes\outfile.txt";

$session = New-Object WinSCP.Session,

# try
# {
# Connect
$session.Open($sessionOptions)

# Transfer files
$session.RemoveFiles("/inout/confiar3/autorizador/BLOQUEOS_MASIVOS.txt")
$session.PutFiles("C:\Users\jrojass\Documents\automatizaciones\ConfiarCooperativaFinanciera\Evidencias\LoadClient\NovedadI\BLOQUEOS_MASIVOS.txt", "/inout/confiar3/autorizador/").Check()
# }
# finally
# {
$session.Dispose()
# }

Write-Host "Write host";
# $NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadI" -TypeCase "Exito" -NumberCase "1"
# Describe "Éxito - $($NameCaseSuccess1): $($_.IdentificationType)-$($_.PersonIdentification)" {
       
#     $chrono = [Diagnostics.Stopwatch]::StartNew()
#     #Consumo de servicio rest con la consulta
        

#     try {
#         Write-Host 'Copiando el archivo de cargue de clientes...'

#         $ConnectSftp = 'protocol=' + $Config.SftpConnection.Protocol + ';host=' + $Config.SftpConnection.Host + ';username=' + $Config.SftpConnection.Username + ';password=' + $Config.SftpConnection.Password + ';fingerprint=' + $Config.SftpConnection.Fingerprint   

#         $LoadLocks = (Get-Item $PathLoadLocks -Filter *.txt).FullName
#         $SftpResponse = $ConnectSftp | Copy-FileToServer -LocalFile $LoadLocks -RemotePath $Config.FtpRemoteDirectoryIn
#             # $ResultData = Invoke-SqlCommand -ConnectionString $ConnectionString -CommandText $PSItem

#         [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
#         $srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') "192.168.60.57"
#         $srv.ConnectionContext.LoginSecure=$false;
#         $srv.ConnectionContext.set_Login("prf");
#         $srv.ConnectionContext.set_Password("Tester2012*/")
#             # $srv.Databases | Select name
#             # $srv.JobServer
#             # $srv.JobServer | Select Jobs
#             # $srv.jobserver.jobs["UniqueCardCajasPro - Confiar - CargaClientesProduccion"]
#         $job = $srv.jobserver.jobs["UniqueCardCajasPro - Confiar - CargaClientesProduccion"]
#         $JobResponse = $job.Start()
#         ##Verificar respuesta del sftp
#         Write-Host 'FTPsucces'

#         $chrono.Stop()

#         ##==> Verificar archivos de realce

#         #Invoca la función que almacena la evidencia del caso
#         #Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Exito_ClienteSinBloqueoEstadoActivoConCorreo'

#         #Write-Host $chrono.Elapsed.TotalSeconds

#         It "Tiempo de respuesta a la solicitud debe ser inferior a $($Config.TimeResponseRequest) seg" {
#             [int] $chrono.Elapsed.TotalSeconds | Should BeLessThan $Config.TimeResponseRequest
#         }

#         #Consulta MongoDB Mensaje de Notificacion de Registro de la cuenta
#         $ResultMongo = Get-KrakenMongo -DocNumber $Request.DocNumber -DocType $Request.DocType -CorrelationalId $Nonce.nonce

#         if ($Config.MessageNotification.MessageEmail -eq 1) {
#             It 'Respuesta petición con correo electrónico enmascarado' {
#                 if ([regex]::Matches($ResultMongo.Properties.Request.CustomData.Email, "(\*+)").value -And [regex]::Matches($ResultMongo.Properties.Response.CustomData.Email, "(\*+)").value ) {
#                     $responseTime = 'True'
#                 }
#                 $responseTime | Should Be 'True'
#             }
#         }

#     }
#     catch {
#         $Response = $_.Exception
#         It 'Fallo en la solicitud del token transaccional' -Skip { }
#     }
        
# }