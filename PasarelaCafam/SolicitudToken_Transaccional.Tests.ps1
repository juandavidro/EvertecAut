$ChildPath = '\Evidencias\'+ $Client+'\SolicitudToken'
$PathEvidencias = Join-Path $PSScriptRoot -ChildPath $ChildPath #Ruta donde se almacenan las evidencias
if (Test-Path -Path $PathEvidencias ) {
}
else {
    New-Item -Path $PathEvidencias -ItemType Directory
}

$ParameterToken = 'Pasarela_' + $Client
$token = Get-AuthenticationToken -Parameter $ParameterToken

Describe 'Validacion de parametros invalidos' {

    #Crea un objeto donde se almacenaran los casos que seran ejecutados con la funcion Test-Alfanumeric
    $Cases = @($null)
    $Cases += Test-Alfanumeric -ParameterName 'DocNumber' -MaxLength 20
    $Cases += Test-Alfanumeric -ParameterName 'DocType' -MaxLength 2 -Nullable
    $Cases += Test-Alfanumeric -ParameterName 'Tags.CustomerGroup' -MinLength 2 -MaxLength 2
    $Cases += @{ Parameter = "DocType"; Value = 'XX'; Description = " no es un acrónimo valido"}

    #Ejecuta los casos de validación

    $Cases.Where( { $_ -ne $null }) | ForEach-Object {
        It $("solicitud debe retornar respuesta con codigo 400 si $($_.Parameter) $($_.Description)") {

            #Crea la estructura basica para el Request de Token
            $Request = New-TokenRequest

            #Asigna el valor del parametro a probar
            $Request.($_.Parameter) = $_.Value

            $Request1 = $Request | ConvertTo-Json

            #Invoca la función que genera el Header para consumir el servicio Rest
            $Header = New-Header -Token $token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {

            #Consume el servicio Rest para la solicitud del token transaccional de la tarjeta
            $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1

            }
            catch {

            $Response = @{'ResponseError' = $Error[0].Exception.Message }
            #Invoca la función que almacena la evidencia del caso
            Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'ValidacionCampos'

            #Realiza la validacion de la respuesta obtenida contra la esperada
            if ([regex]::Matches($Response.ResponseError, "4[0-9][0-9]").value) {
                $responseCode = 'True'
            }

            $responseCode | Should Be 'True'
            }

        }

    }

}

Describe 'Casos Exito - Solicitud Token Transaccional' {

    Write-Host 'Obteniendo informacion de la base de datos...'
    $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'ClientesTipoIdentificacion'
    if (!$ConsultaClientes -eq '') {
        $ConsultaClientes | ForEach-Object {
            Context "CAF-768 Cliente sin bloqueo y en estado activo: $($_.IdentificationType)-$($_.PersonIdentification)" {

                #Construccion del Request
                $Request = New-TokenRequest
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.DocNumber = $_.PersonIdentification
                $Request.DocType = $_.IdentificationType
                $Request1 = $Request | ConvertTo-Json
                #Generacion del header
                $Header = New-Header -Token $token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1
                #Detiene el cronometro
                $chrono.Stop()

                #Invoca la función que almacena la evidencia del caso
                Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Exito_ClienteSinBloqueoEstadoActivoConCorreo'

                Write-Host $chrono.Elapsed.TotalSeconds

                It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                    if ($chrono.Elapsed.TotalSeconds -lt 10) {
                        $responseTime = 'True'
                    }
                    $responseTime | Should Be 'True'
                }

                #Consulta MongoDB Mensaje de Notificacion de Registro de la cuenta
                $ResultMongo = Get-KrakenMongo -DocNumber $Request.DocNumber -DocType $Request.DocType -CorrelationalId $Nonce.nonce

                It 'Respuesta petición con correo electrónico enmascarado' {
                    if ([regex]::Matches($ResultMongo.Properties.Request.CustomData.Email, "(\*+)").value -And [regex]::Matches($ResultMongo.Properties.Response.CustomData.Email, "(\*+)").value ) {
                        $responseTime = 'True'
                    }
                $responseTime | Should Be 'True'
                }

                #Función que retorna el contenido del mensaje enviado con el token
                #$Email = Get-ContentNotification

                It 'Email con token en el correo del cliente' {
                    if ([regex]::Matches($ResultMongo.Properties.Request.Message, "[0-9]{6}").value ) {
                        $messageEmail = 'True'
                    }
                    $messageEmail | Should Be 'True'
                }
                It 'Email con mensaje correcto' {
                    if ($ResultMongo.Properties.Request.Message) {
                        if ([regex]::Matches($ResultMongo.Properties.Request.Message, $EmailContent.MensajeEmail).value ) {
                            $contentEmail = 'True'
                        }
                    }
                    $contentEmail | Should Be 'True'
                }
                It 'Email informa la vigencia del token de 5 minutos' {
                    if ($ResultMongo.Properties.Request.Message.Length) {
                        if ([regex]::Matches($ResultMongo.Properties.Request.Message, "Vigencia 5 minutos").value ) {
                            $contentEmail = 'True'
                        }
                    }
                    $contentEmail | Should Be 'True'
                }
                It 'Formato correcto del token' {
                    if ([regex]::Matches($ResultMongo.Properties.Request.Message, "[0-9]{6}").value ) {
                            $contentEmailToken = 'True'
                    }
                    $contentEmailToken | Should Be 'True'
                }
            }
        }
    }

    $ConsultaClienteActivo = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'ClienteActivoConBloqueo'
    if (!$ConsultaClienteActivo -eq '') {
        $ConsultaClienteActivo | ForEach-Object {
            Context "CAF-769 Cliente activo, con bloqueo con correo: $($_.Acronym)-$($_.PersonIdentification)" {

                #Construccion del Request
                $Request = New-TokenRequest
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.DocNumber = $_.PersonIdentification
                $Request.DocType = $_.Acronym
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1
                #Detiene el cronometro
                $chrono.Stop()

                #Invoca la función que almacena la evidencia del caso
                Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Exito_ClienteActivoConBloqueoConCorreo'

                Write-Host $chrono.Elapsed.TotalSeconds

                It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                    if ($chrono.Elapsed.TotalSeconds -lt 10) {
                        $responseTime = 'True'
                    }
                    $responseTime | Should Be 'True'
                }

                #Consulta MongoDB Mensaje de Notificacion de Registro de la cuenta
                $ResultMongo = Get-KrakenMongo -DocNumber $Request.DocNumber -DocType $Request.DocType -CorrelationalId $Nonce.nonce

                It 'Respuesta petición con correo electrónico enmascarado' {
                    if ([regex]::Matches($ResultMongo.Properties.Request.CustomData.Email, "(\*+)").value -And [regex]::Matches($ResultMongo.Properties.Response.CustomData.Email, "(\*+)").value ) {
                        $responseTime = 'True'
                    }
                $responseTime | Should Be 'True'
                }

                #Función que retorna el contenido del mensaje enviado con el token
                #$Email = Get-ContentNotification

                It 'Email con token en el correo del cliente' {
                    if ([regex]::Matches($ResultMongo.Properties.Request.Message, "[0-9]{6}").value ) {
                        $messageEmail = 'True'
                    }
                    $messageEmail | Should Be 'True'
                }
                It 'Email con mensaje correcto' {
                    if ($ResultMongo.Properties.Request.Message) {
                        if ([regex]::Matches($ResultMongo.Properties.Request.Message, $EmailContent.MensajeEmail).value ) {
                            $contentEmail = 'True'
                        }
                    }
                    $contentEmail | Should Be 'True'
                }
                It 'Email informa la vigencia del token de 5 minutos' {
                    if ($ResultMongo.Properties.Request.Message.Length) {
                        if ([regex]::Matches($ResultMongo.Properties.Request.Message, "Vigencia 5 minutos").value ) {
                            $contentEmail = 'True'
                        }
                    }
                    $contentEmail | Should Be 'True'
                }
                It 'Formato correcto del token' {
                    if ([regex]::Matches($ResultMongo.Properties.Request.Message, "[0-9]{6}").value ) {
                            $contentEmailToken = 'True'
                    }
                    $contentEmailToken | Should Be 'True'
                }
            }
        }
    }


    $ConsultaClienteInactivo = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'ClienteInactivoSinBloqueo'
    if (!$ConsultaClienteInactivo -eq '') {
        $ConsultaClienteInactivo | ForEach-Object {
            Context "CAF-770 Cliente inactivo, sin bloqueo con correo: $($_.IdentificationType)-$($_.PersonIdentification)" {

                #Construccion del Request
                $Request = New-TokenRequest
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.DocNumber = $_.PersonIdentification
                $Request.DocType = $_.IdentificationType
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1
                #Detiene el cronometro
                $chrono.Stop()

                #Invoca la función que almacena la evidencia del caso
                Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Exito_ClienteSinBloqueoInactivoConCorreo'

                Write-Host $chrono.Elapsed.TotalSeconds

                It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                    if ($chrono.Elapsed.TotalSeconds -lt 10) {
                        $responseTime = 'True'
                    }
                    $responseTime | Should Be 'True'
                }

                #Consulta MongoDB Mensaje de Notificacion de Registro de la cuenta
                $ResultMongo = Get-KrakenMongo -DocNumber $Request.DocNumber -DocType $Request.DocType -CorrelationalId $Nonce.nonce

                It 'Email con token en el correo del cliente' {
                    if ([regex]::Matches($ResultMongo.Properties.Request.Message, "[0-9]{6}").value ) {
                        $messageEmail = 'True'
                    }
                    $messageEmail | Should Be 'True'
                }
                It 'Email con mensaje correcto' {
                    if ($ResultMongo.Properties.Request.Message) {
                        if ([regex]::Matches($ResultMongo.Properties.Request.Message, $EmailContent.MensajeEmail).value ) {
                            $contentEmail = 'True'
                        }
                    }
                    $contentEmail | Should Be 'True'
                }
                It 'Email informa la vigencia del token de 5 minutos' {
                    if ($ResultMongo.Properties.Request.Message.Length) {
                        if ([regex]::Matches($ResultMongo.Properties.Request.Message, "Vigencia 5 minutos").value ) {
                            $contentEmail = 'True'
                        }
                    }
                    $contentEmail | Should Be 'True'
                }
                It 'Formato correcto del token' {
                    if ([regex]::Matches($ResultMongo.Properties.Request.Message, "[0-9]{6}").value ) {
                            $contentEmailToken = 'True'
                    }
                    $contentEmailToken | Should Be 'True'
                }
            }
        }
    }
}


Describe 'Casos de Excepción - Solicitud Token Transaccional' {
    Context 'CAF-771 Cliente que no existe' {
        #$RequestDataRow = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'TarjetaAsociada'
        $RandomNumber = Get-Random -Minimum 1000000 -Maximum 1000000000
        $Request = New-TokenRequest
        $Request.DocType = 'TI'
        $Request.Tags.CustomerGroup = '01'
        $Request.DocNumber = $RandomNumber
        $Request1 = $Request | ConvertTo-Json

        #Generacion del header
        $Header = New-Header -Token $token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
        $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

        try {
            #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
            $chrono = [Diagnostics.Stopwatch]::StartNew()
            #Consumo de servicio rest con la consulta
            $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1
            #Detiene el cronometro
            $chrono.Stop()
        }
        catch {
            $Response = @{'ResponseError' = $Error[0].Exception.Message }
            Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ClienteNoExiste'
            It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                if ($chrono.Elapsed.TotalSeconds -lt 10) {
                    $responseTime = 'True'
                }
                $responseTime | Should Be 'True'
            }
            It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                $ResponseError = $Response.ResponseError
                if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                    $ResponseError = 'True'
                }
                $ResponseError | Should Be 'True'
            }
            #Consulta MongoDB Mensaje de Notificacion de Registro de la cuenta
            $ResultMongo = Get-KrakenMongo -DocNumber $Request.DocNumber -DocType $Request.DocType -CorrelationalId $Nonce.nonce

            It 'Correo electrónico no enviado' {
                if ([regex]::Matches($ResultMongo.Properties.Response.ResponseMessage, "El Afiliado no posee una dirección de correo para el envío del mensaje.").value ) {
                    $responseTime = 'True'
                }
                $responseTime | Should Be 'True'
            }
        }
    }

    $ConsultaClienteSinCorreo = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'ClienteActivoSinCorreo'
    if (!$ConsultaClienteSinCorreo -eq '') {
        $ConsultaClienteSinCorreo | ForEach-Object {
            Context "CAF-772 Cliente activo, sin bloqueo y sin correo registrado: $($_.Acronym)-$($_.PersonIdentification)" {

                #Construccion del Request
                $Request = New-TokenRequest
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.DocNumber = $_.PersonIdentification
                $Request.DocType = $_.Acronym
                $Request1 = $Request | ConvertTo-Json
                #Generacion del header
                $Header = New-Header -Token $token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1
                    #Detiene el cronometro
                    $chrono.Stop()
                }
                catch {
                    $Response = @{'ResponseError' = $Error[0].Exception.Message }
                    Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ClienteActivoSinBloqueoSinCorreo'
                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseErrorEmail = $Response.ResponseError
                        if ([regex]::Matches($ResponseErrorEmail, "4[0-9][0-9]").value) {
                            $ResponseErrorEmail = 'True'
                        }
                        $ResponseErrorEmail | Should Be 'True'
                    }
                }
            }
        }
    }

    $ConsultaClienteCorreoErroneo = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'ClienteCorreoErroneo'
    if (!$ConsultaClienteCorreoErroneo -eq '') {
        $ConsultaClienteCorreoErroneo | ForEach-Object {
            Context "CAF-773 Cliente con correo erroneo: $($_.Acronym)-$($_.PersonIdentification)" {

                #Construccion del Request
                $Request = New-TokenRequest
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.DocNumber = $_.PersonIdentification
                $Request.DocType = $_.Acronym
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1
                    #Detiene el cronometro
                    $chrono.Stop()
                }
                catch {
                    $Response = @{'ResponseError' = $Error[0].Exception.Message }
                    Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ClienteCorreoErroneo'
                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 503 - Segun Mensajes de respuesta de Aspen' {
                        $ResponseErrorWrong = $Response.ResponseError
                        if ([regex]::Matches($ResponseErrorWrong, "503").value) {
                            $ResponseErrorWrong = 'True'
                        }
                        $ResponseErrorWrong | Should Be 'True'
                    }
                }
            }
        }
    }


    $ConsultaClienteCustomerGroupErroneo = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'ClienteCustomerGroupErroneo'
    if (!$ConsultaClienteCustomerGroupErroneo -eq '') {
        $ConsultaClienteCustomerGroupErroneo | ForEach-Object {
            Context "CAF-775 Cliente con CustomerGroup erroneo: $($_.Acronym)-$($_.PersonIdentification)" {

                #Construccion del Request
                $Request = New-TokenRequest
                $Request.Tags.CustomerGroup = '02'
                $Request.DocNumber = $_.PersonIdentification
                $Request.DocType = $_.Acronym
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1
                    #Detiene el cronometro
                    $chrono.Stop()
                }
                catch {
                    $Response = @{'ResponseError' = $Error[0].Exception.Message }
                    Save-Evidence -Request $Request -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ClienteCustomerGroupErroneo'
                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseErrorCustomer = $Response.ResponseError
                        if ([regex]::Matches($ResponseErrorCustomer, "4[0-9][0-9]").value) {
                            $ResponseErrorCustomer = 'True'
                        }
                        $ResponseErrorCustomer | Should Be 'True'
                    }
                }
            }
        }
    }
}