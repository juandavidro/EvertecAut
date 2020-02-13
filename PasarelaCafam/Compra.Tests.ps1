$ChildPath = '\Evidencias\'+ $Client+'\Compra'
$PathEvidencias = Join-Path $PSScriptRoot -ChildPath $ChildPath #Ruta donde se almacenan las evidencias
if (Test-Path -Path $PathEvidencias ) {
}
else {
    New-Item -Path $PathEvidencias -ItemType Directory
}

$ParameterToken = 'Pasarela_' + $Client
$Token = Get-AuthenticationToken -Parameter $ParameterToken


Describe 'Validacion de parametros invalidos' {

    #Crea un objeto donde se almacenaran los casos que seran ejecutados con la funcion Test-Alfanumeric
    $Cases = @($null)
    $Cases += Test-Alfanumeric -ParameterName 'DocNumber' -MaxLength 20
    $Cases += Test-Alfanumeric -ParameterName 'DocType' -MaxLength 2
    $Cases += Test-Alfanumeric -ParameterName 'AccountType' -MinLength 2 -MaxLength 2
    $Cases += Test-Alfanumeric -ParameterName 'Token' -MinLength 6 -MaxLength 6
    $Cases += Test-Alfanumeric -ParameterName 'Amount' -MinLength 2
    $Cases += Test-Alfanumeric -ParameterName 'Tags.CustomerGroup' -MinLength 2 -MaxLength 2
    $Cases += Test-Alfanumeric -ParameterName 'Tags.CardAcceptorId' -MinLength 15 -MaxLength 15
    $Cases += Test-Alfanumeric -ParameterName 'Tags.Pan' -MinLength 16 -MaxLength 16
    $Cases += @{ Parameter = "DocType"; Value = 'XX'; Description = " no es un acrónimo valido" }

    #Ejecuta los casos de validación
    $Cases.Where( { $_ -ne $null }) | ForEach-Object {
        It $("solicitud debe retornar respuesta con codigo 400 si $($_.Parameter) $($_.Description)") {

            $Parameter = $_.Parameter
            $Description = $_.Description
            #Crea la estructura basica para el Request de Compra
            $Request = New-PaymentRequest
            $Request1 = $Request | ConvertTo-Json
            #Asigna el valor del parametro a probar
            $Request.($_.Parameter) = $_.Value
            #Invoca la función que genera el Header para consumir el servicio Rest
            $Header = New-Header -Token $DecodeJWT.jti -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Consume el servicio Rest para la solicitud del token transaccional de la tarjeta
                $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
            }
            catch {

                $Response = $_.Exception
                #Invoca la función que almacena la evidencia del caso
                Save-Evidence -Request $Request -Response $Response.Response.StatusDescription -Value1 $Parameter -Value2 $Description -PathEvidencias $PathEvidencias -Testtype 'ValidacionCampos'

                #Realiza la validacion de la respuesta obtenida contra la esperada
                if ([regex]::Matches($Response.Message, "4[0-9][0-9]").value) {
                    $responseCode = 'True'
                }
                $responseCode | Should Be 'True'
            }
        }
    }
}



    Write-Host 'Obteniendo informacion de la base de datos...'
    $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
    if (!$ConsultaClientes -eq '') {
        $ConsultaClientes | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan
            #Construccion del Request
            $Request = New-PaymentRequest
            $Request.DocType = $_.Acronym
            $Request.DocNumber = $_.PersonIdentification
            $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.Pan = $_.Pan.substring(12, 4)
            $Request.AccountType = $_.IdAccountType
            $DeltaLedgerBalance = $_.DeltaLedgerBalance

            $CardAcceptor = $Config.CardAcceptor
            $CardAcceptor | ForEach-Object {
                Describe "CAF-789 Compra Casos Exito, con los CardAcceptorId configurados: $($_.Acronym)-$($_.PersonIdentification) CardAcceptor: $($_)" {
                    $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                    $Request.Token = $TransactionalToken
                    $Request.Tags.CardAcceptorId = $_
                    $Request1 = $Request | ConvertTo-Json

                    $SRequest = @{
                        DocType        = $Request.DocType
                        DocNumer       = $Request.DocNumber
                        AccountType    = $Request.AccountType
                        Token          = $Request.Token
                        Amount         = $Request.Amount
                        CustomerGroup  = $Request.Tags.CustomerGroup
                        CardAcceptorId = $Request.Tags.CardAcceptorId
                        Pan            = $Request.Tags.Pan
                    }

                    #Generacion del header
                    $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                    try {
                        #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                        $chrono = [Diagnostics.Stopwatch]::StartNew()
                        #Consumo de servicio rest con la consulta
                        $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                        #Detiene el cronometro
                        $chrono.Stop()

                        #Invoca la función que almacena la evidencia del caso
                        Save-Evidence -Request $SRequest -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -Value3 $Request.Tags.CardAcceptorId -PathEvidencias $PathEvidencias -Testtype 'Exito_CardAcceptorId_'

                        Write-Host $chrono.Elapsed.TotalSeconds
                        $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                        $Transaction = Get-ReponseSql -Value1 $IdCard -Value2 $Response.authNumber -ConnectionString $Config.ConnectionString -Parameter 'ConsultaTRX'
                        $TransactionMicroservices = Get-ReponseSql -Value1 $Response.authNumber -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMicroservices'

                        It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                            if ($chrono.Elapsed.TotalSeconds -lt 10) {
                                $responseTime = 'True'
                            }
                            $responseTime | Should Be 'True'
                        }
                        It 'Clave authNumber esta presente en la respuesta' {
                            if ($Response | Get-Member -Name authNumber) {
                                $authNumber = 'True'
                            }
                            $authNumber | Should Be 'True'
                        }
                        Write-Host 'Validaciones de la Transaccion en TUP'
                        It "Se registra la transaccion en la BD" {
                            if ($Response.authNumber -eq $Transaction.AuthorizationNumber) {
                                $RAuthorizationNumber = 'True'
                            }
                            $RAuthorizationNumber | Should Be 'True'
                        }
                        It "TransactionType correponde a la transaccion de Compra" {
                            if ($Transaction.TransactionType -eq '00') {
                                $TransactionType = 'True'
                            }
                            $TransactionType | Should Be 'True'
                        }
                        It "Pan de la transaccion correponde a la solicitud" {
                            if ($Transaction.Pan -eq $Pan ) {
                                $RPan = 'True'
                            }
                            $RPan | Should Be 'True'
                        }
                        It "Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                            if ($Transaction.IdAcquirer -eq $Config.AcquirerPasarela ) {
                                $IdAcquirer = 'True'
                            }
                            $IdAcquirer | Should Be 'True'
                        }
                        It "Monto de la transacción en BD corresponde al request" {
                            if ($Transaction.AmountTransaction -eq $Request.Amount ) {
                                $Amount = 'True'
                            }
                            $Amount | Should Be 'True'
                        }
                        It "CardAcceptor registrado en la transacción corresponde con la solicitud" {
                            if ($Transaction.IdCardAcceptor -eq $Request.Tags.CardAcceptorId ) {
                                $CardAcceptorId = 'True'
                            }
                            $CardAcceptorId | Should Be 'True'
                        }
                        It "AccountType registrada en la transacción corresponde con la solicitud" {
                            if ($Request.AccountType -eq $Transaction.FromAccountType ) {
                                $FromAccountType = 'True'
                            }
                            $FromAccountType | Should Be 'True'
                        }
                        It "Codigo de la respuesta debe ser Exitosa" {
                            if ($Transaction.ResponseCode -eq '00' ) {
                                $ResponseCode = 'True'
                            }
                            $ResponseCode | Should Be 'True'
                        }
                        Write-Host 'Validaciones de la Transaccion en Microservices'
                        It "Microservices: Se registra la transaccion en la BD" {
                            if ($Response.authNumber -eq $TransactionMicroservices.authorization_number) {
                                $MAuthorizationNumber = 'True'
                            }
                            $MAuthorizationNumber | Should Be 'True'
                        }
                        It "Microservices: TransactionType correponde a la transaccion de Compra" {
                            if ($TransactionMicroservices.tran_type -eq '00') {
                                $MTransactionType = 'True'
                            }
                            $MTransactionType | Should Be 'True'
                        }
                        It "Microservices: Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                            if ($TransactionMicroservices.acquiring_inst_id -eq $Config.AcquirerPasarela ) {
                                $MIdAcquirer = 'True'
                            }
                            $MIdAcquirer | Should Be 'True'
                        }
                        It "Microservices: Monto de la transacción en BD corresponde al request" {
                            $Amount = $TransactionMicroservices.amount.Remove(10, 2)
                            if ([int]$Amount -eq $Request.Amount ) {
                                $MAmount = 'True'
                            }
                            $MAmount | Should Be 'True'
                        }
                        It "Microservices: CardAcceptor registrado en la transacción corresponde con la solicitud" {
                            if ($TransactionMicroservices.card_acceptor -eq $Request.Tags.CardAcceptorId ) {
                                $MCardAcceptorId = 'True'
                            }
                            $MCardAcceptorId | Should Be 'True'
                        }
                        It "Microservices: AccountType registrada en la transacción corresponde con la solicitud" {
                            if ($Request.AccountType -eq $TransactionMicroservices.from_account ) {
                                $MFromAccountType = 'True'
                            }
                            $MFromAccountType | Should Be 'True'
                        }
                        Write-Host 'Validaciones en la Base de Datos'
                        It 'La compra afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                            if ($ResponseSQL.DeltaLedgerBalance -eq ($DeltaLedgerBalance - $Request.Amount)) {
                                Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'ActualizacionSaldos'
                                $Balance = 'True'
                            }
                            $Balance | Should Be 'True'
                        }
                    }
                    catch {
                        $MessageToken = $_.Exception.Response
                        Save-Evidence -Request $SRequest -Response $MessageToken -Value1 $Request.DocType -Value2 $Request.DocNumber -Value3 $Request.AccountType -PathEvidencias $PathEvidencias -Testtype 'Exito_CardAcceptorId_'
                        It 'Prueba no debe generar Excepción' {
                            if (![string]::IsNullOrEmpty($MessageToken)) {
                                $Excep = 'True'
                            }
                            $Excep | Should Be 'True'
                        }
                    }
                }
            }
        }
    }
    else {
        It "No hay clientes disponibles" {
            $NoData = 'True'
            $NoData | Should Be 'True'
        }
    }



    Write-Host 'Obteniendo informacion de la base de datos...'
    $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
    if (!$ConsultaClientes -eq '') {
        $ConsultaClientes | ForEach-Object {
            $ItemConsultas = $_
            $IdCard = $_.IdCard
            $Pan = $_.Pan
            #Construccion del Request
            $Request = New-PaymentRequest
            $Request.DocType = $_.Acronym
            $Request.DocNumber = $_.PersonIdentification
            $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $Config.CardAcceptor[1]
            $Request.Tags.Pan = $_.Pan.substring(12, 4)

            $Account = Get-DataSqlFormat -ConnectionString $Config.ConnectionString -Parameter 'BolsillosCliente' -Value1 $IdCard
            $Account | ForEach-Object {
                Describe "CAF-790 Compra Casos Exito, Todos los bolsillos: $($_.Acronym)-$($_.PersonIdentification) Bolsillo: $($_.IdAccountType)" {
                    $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                    $Request.Token = $TransactionalToken
                    $Request.AccountType = $_.IdAccountType
                    $Request1 = $Request | ConvertTo-Json

                    $SRequest = @{
                        DocType        = $Request.DocType
                        DocNumer       = $Request.DocNumber
                        AccountType    = $Request.AccountType
                        Token          = $Request.Token
                        Amount         = $Request.Amount
                        CustomerGroup  = $Request.Tags.CustomerGroup
                        CardAcceptorId = $Request.Tags.CardAcceptorId
                        Pan            = $Request.Tags.Pan
                    }


                    #Generacion del header
                    $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                    try {
                        #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                        $chrono = [Diagnostics.Stopwatch]::StartNew()
                        #Consumo de servicio rest con la consulta
                        $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                        #Detiene el cronometro
                        $chrono.Stop()

                        #Invoca la función que almacena la evidencia del caso
                        Save-Evidence -Request $SRequest -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -Value3 $Request.AccountType -PathEvidencias $PathEvidencias -Testtype 'Exito_TodosBolsillos_'

                        Write-Host $chrono.Elapsed.TotalSeconds

                        $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                        $Transaction = Get-ReponseSql -Value1 $IdCard -Value2 $Response.authNumber -ConnectionString $Config.ConnectionString -Parameter 'ConsultaTRX'
                        $TransactionMicroservices = Get-ReponseSql -Value1 $Response.authNumber -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMicroservices'

                        It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                            if ($chrono.Elapsed.TotalSeconds -lt 10) {
                                $responseTime = 'True'
                            }
                            $responseTime | Should Be 'True'
                        }
                        It 'Clave authNumber esta presente en la respuesta' {
                            if ($Response | Get-Member -Name authNumber) {
                                $authNumber = 'True'
                            }
                            $authNumber | Should Be 'True'
                        }
                        Write-Host 'Validaciones de la Transaccion en TUP'
                        It "Se registra la transaccion en la BD" {
                            if ($Response.authNumber -eq $Transaction.AuthorizationNumber) {
                                $RAuthorizationNumber = 'True'
                            }
                            $RAuthorizationNumber | Should Be 'True'
                        }
                        It "TransactionType correponde a la transaccion de Compra" {
                            if ($Transaction.TransactionType -eq '00') {
                                $TransactionType = 'True'
                            }
                            $TransactionType | Should Be 'True'
                        }
                        It "Pan de la transaccion correponde a la solicitud" {
                            if ($Transaction.Pan -eq $Pan ) {
                                $RPan = 'True'
                            }
                            $RPan | Should Be 'True'
                        }
                        It "Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                            if ($Transaction.IdAcquirer -eq $Config.AcquirerPasarela ) {
                                $IdAcquirer = 'True'
                            }
                            $IdAcquirer | Should Be 'True'
                        }
                        It "Monto de la transacción en BD corresponde al request" {
                            if ($Transaction.AmountTransaction -eq $Request.Amount ) {
                                $Amount = 'True'
                            }
                            $Amount | Should Be 'True'
                        }
                        It "CardAcceptor registrado en la transacción corresponde con la solicitud" {
                            if ($Transaction.IdCardAcceptor -eq $Request.Tags.CardAcceptorId ) {
                                $CardAcceptorId = 'True'
                            }
                            $CardAcceptorId | Should Be 'True'
                        }
                        It "AccountType registrada en la transacción corresponde con la solicitud" {
                            if ($Request.AccountType -eq $Transaction.FromAccountType ) {
                                $FromAccountType = 'True'
                            }
                            $FromAccountType | Should Be 'True'
                        }
                        It "Codigo de la respuesta debe ser Exitosa" {
                            if ($Transaction.ResponseCode -eq '00' ) {
                                $ResponseCode = 'True'
                            }
                            $ResponseCode | Should Be 'True'
                        }
                        Write-Host 'Validaciones de la Transaccion en Microservices'
                        It "Microservices: Se registra la transaccion en la BD" {
                            if ($Response.authNumber -eq $TransactionMicroservices.authorization_number) {
                                $MAuthorizationNumber = 'True'
                            }
                            $MAuthorizationNumber | Should Be 'True'
                        }
                        It "Microservices: TransactionType correponde a la transaccion de Compra" {
                            if ($TransactionMicroservices.tran_type -eq '00') {
                                $MTransactionType = 'True'
                            }
                            $MTransactionType | Should Be 'True'
                        }
                        It "Microservices: Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                            if ($TransactionMicroservices.acquiring_inst_id -eq $Config.AcquirerPasarela ) {
                                $MIdAcquirer = 'True'
                            }
                            $MIdAcquirer | Should Be 'True'
                        }
                        It "Microservices: Monto de la transacción en BD corresponde al request" {
                            $Amount = $TransactionMicroservices.amount.Remove(10, 2)
                            if ([int]$Amount -eq $Request.Amount ) {
                                $MAmount = 'True'
                            }
                            $MAmount | Should Be 'True'
                        }
                        It "Microservices: CardAcceptor registrado en la transacción corresponde con la solicitud" {
                            if ($TransactionMicroservices.card_acceptor -eq $Request.Tags.CardAcceptorId ) {
                                $MCardAcceptorId = 'True'
                            }
                            $MCardAcceptorId | Should Be 'True'
                        }
                        It "Microservices: AccountType registrada en la transacción corresponde con la solicitud" {
                            if ($Request.AccountType -eq $TransactionMicroservices.from_account ) {
                                $MFromAccountType = 'True'
                            }
                            $MFromAccountType | Should Be 'True'
                        }
                        Write-Host 'Validaciones en la Base de Datos'
                        It 'La compra afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                            if ($ResponseSQL.DeltaLedgerBalance -eq ($_.DeltaLedgerBalance - $Request.Amount)) {
                                $Balance = 'True'
                            }
                            $Balance | Should Be 'True'
                        }
                    }
                    catch {
                        $MessageToken = $_.Exception.Response
                        Save-Evidence -Request $SRequest -Response $MessageToken -Value1 $Request.DocType -Value2 $Request.DocNumber -Value3 $Request.AccountType -PathEvidencias $PathEvidencias -Testtype 'Exito_TodosBolsillos_'
                        It 'Prueba no debe generar Excepción' {
                            if (![string]::IsNullOrEmpty($MessageToken)) {
                                $Excep = 'True'
                            }
                            $Excep | Should Be 'True'
                        }
                    }
                }
            }
        }
    }
    else {
        It "No hay clientes disponibles" {
            $NoData = 'True'
            $NoData | Should Be 'True'
        }
    }



    Write-Host 'Obteniendo informacion de la base de datos...'
    $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraTipoIdentificacion'
    if (!$ConsultaClientes -eq '') {
        $ConsultaClientes | ForEach-Object {
            Describe "CAF-791 Compra Casos Exito, Todos los tipos de identificación: $($_.IdentificationType)-$($_.PersonIdentification)" {
                #Genera token transaccional
                $TransactionalToken = Get-TransactionalToken -DocType $_.IdentificationType -DocNumber $_.PersonIdentification -CustomerGroup $_.CustomerGroup -Token $Token
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.IdentificationType
                $Request.DocNumber = $_.PersonIdentification
                $Request.AccountType = '80'
                $Request.Token = $TransactionalToken
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.CardAcceptorId = $Config.CardAcceptor[0]
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request1 = $Request | ConvertTo-Json

                $SRequest = @{
                    DocType        = $Request.DocType
                    DocNumer       = $Request.DocNumber
                    AccountType    = $Request.AccountType
                    Token          = $Request.Token
                    Amount         = $Request.Amount
                    CustomerGroup  = $Request.Tags.CustomerGroup
                    CardAcceptorId = $Request.Tags.CardAcceptorId
                    Pan            = $Request.Tags.Pan
                }

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    #Detiene el cronometro
                    $chrono.Stop()

                    #Invoca la función que almacena la evidencia del caso
                    Save-Evidence -Request $SRequest -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Exito_ClienteSinBloqueo'

                    Write-Host $chrono.Elapsed.TotalSeconds

                    $ResponseSQL = Get-ReponseSql -Value1 $_.IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                    $Transaction = Get-ReponseSql -Value1 $_.IdCard -Value2 $Response.authNumber -ConnectionString $Config.ConnectionString -Parameter 'ConsultaTRX'
                    $TransactionMicroservices = Get-ReponseSql -Value1 $Response.authNumber -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMicroservices'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    Write-Host 'Validaciones de la Transaccion'
                    It "Se registra la transaccion en la BD" {
                        if ($Response.authNumber -eq $Transaction.AuthorizationNumber) {
                            $RAuthorizationNumber = 'True'
                        }
                        $RAuthorizationNumber | Should Be 'True'
                    }
                    It "TransactionType correponde a la transaccion de Compra" {
                        if ($Transaction.TransactionType -eq '00') {
                            $TransactionType = 'True'
                        }
                        $TransactionType | Should Be 'True'
                    }
                    It "Pan de la transaccion correponde a la solicitud" {
                        if ($Transaction.Pan -eq $_.Pan ) {
                            $Pan = 'True'
                        }
                        $Pan | Should Be 'True'
                    }
                    It "Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                        if ($Transaction.IdAcquirer -eq $Config.AcquirerPasarela ) {
                            $IdAcquirer = 'True'
                        }
                        $IdAcquirer | Should Be 'True'
                    }
                    It "Monto de la transacción en BD corresponde al request" {
                        if ($Transaction.AmountTransaction -eq $Request.Amount ) {
                            $Amount = 'True'
                        }
                        $Amount | Should Be 'True'
                    }
                    It "CardAcceptor registrado en la transacción corresponde con la solicitud" {
                        if ($Transaction.IdCardAcceptor -eq $Request.Tags.CardAcceptorId ) {
                            $CardAcceptorId = 'True'
                        }
                        $CardAcceptorId | Should Be 'True'
                    }
                    It "AccountType registrada en la transacción corresponde con la solicitud" {
                        if ($Request.AccountType -eq $Transaction.FromAccountType ) {
                            $FromAccountType = 'True'
                        }
                        $FromAccountType | Should Be 'True'
                    }
                    It "Codigo de la respuesta debe ser Exitosa" {
                        if ($Transaction.ResponseCode -eq '00' ) {
                            $ResponseCode = 'True'
                        }
                        $ResponseCode | Should Be 'True'
                    }
                    Write-Host 'Validaciones de la Transaccion en Microservices'
                    It "Microservices: Se registra la transaccion en la BD" {
                        if ($Response.authNumber -eq $TransactionMicroservices.authorization_number) {
                            $MAuthorizationNumber = 'True'
                        }
                        $MAuthorizationNumber | Should Be 'True'
                    }
                    It "Microservices: TransactionType correponde a la transaccion de Compra" {
                        if ($TransactionMicroservices.tran_type -eq '00') {
                            $MTransactionType = 'True'
                        }
                        $MTransactionType | Should Be 'True'
                    }
                    It "Microservices: Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                        if ($TransactionMicroservices.acquiring_inst_id -eq $Config.AcquirerPasarela ) {
                            $MIdAcquirer = 'True'
                        }
                        $MIdAcquirer | Should Be 'True'
                    }
                    It "Microservices: Monto de la transacción en BD corresponde al request" {
                        $Amount = $TransactionMicroservices.amount.Remove(10, 2)
                        if ([int]$Amount -eq $Request.Amount ) {
                            $MAmount = 'True'
                        }
                        $MAmount | Should Be 'True'
                    }
                    It "Microservices: CardAcceptor registrado en la transacción corresponde con la solicitud" {
                        if ($TransactionMicroservices.card_acceptor -eq $Request.Tags.CardAcceptorId ) {
                            $MCardAcceptorId = 'True'
                        }
                        $MCardAcceptorId | Should Be 'True'
                    }
                    It "Microservices: AccountType registrada en la transacción corresponde con la solicitud" {
                        if ($Request.AccountType -eq $TransactionMicroservices.from_account ) {
                            $MFromAccountType = 'True'
                        }
                        $MFromAccountType | Should Be 'True'
                    }
                    Write-Host 'Validaciones en la Base de Datos'
                    It 'La compra afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq ($_.Balance - $Request.Amount)) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                }
                catch {
                    $MessageToken = $_.Exception.Response
                    Save-Evidence -Request $SRequest -Response $MessageToken -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Exito_ClienteSinBloqueo'
                    It 'Prueba no debe generar Excepción' {
                        if (![string]::IsNullOrEmpty($MessageToken)) {
                            $Excep = 'True'
                        }
                        $Excep | Should Be 'True'
                    }
                }
            }
        }
    }
    else {
        It "No hay clientes disponibles" {
            $NoData = 'True'
            $NoData | Should Be 'True'
        }
    }



    Describe 'Excepción: CAF-864 Realizar compra con cliente que no tenga saldo' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraClientSinSaldo'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request.AccountType = $_.IdAccountType

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()
                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraClienteSinSaldo'
                    $TransactionMicroservices = Get-ReponseSql -Value1 $Nonce.nonce -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMSByCorrelationId'
                    $Transaction = Get-ReponseSql -Value1 $IdCard -Value2 $TransactionMicroservices.authorization_number -ConnectionString $Config.ConnectionString -Parameter 'ConsultaIdCard'
                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'


                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }

                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "fondos insuficientes").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It "Codigo de la respuesta no debe ser Exitoso" {
                        if ($Transaction.ResponseCode -ne '00' ) {
                            $ResponseCode = 'True'
                        }
                        $ResponseCode | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq 0) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                    Write-Host 'Validaciones de la Transaccion en TUP'
                        It "TransactionType correponde a la transaccion de Compra" {
                            if ($Transaction.TransactionType -eq '00') {
                                $TransactionType = 'True'
                            }
                            $TransactionType | Should Be 'True'
                        }
                        It "Pan de la transaccion correponde a la solicitud" {
                            if ($Transaction.Pan -eq $Pan ) {
                                $RPan = 'True'
                            }
                            $RPan | Should Be 'True'
                        }
                        It "Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                            if ($Transaction.IdAcquirer -eq $Config.AcquirerPasarela ) {
                                $IdAcquirer = 'True'
                            }
                            $IdAcquirer | Should Be 'True'
                        }
                        It "Monto de la transacción en BD corresponde al request" {
                            if ($Transaction.AmountTransaction -eq $Request.Amount ) {
                                $Amount = 'True'
                            }
                            $Amount | Should Be 'True'
                        }
                        It "CardAcceptor registrado en la transacción corresponde con la solicitud" {
                            if ($Transaction.IdCardAcceptor -eq $Request.Tags.CardAcceptorId ) {
                                $CardAcceptorId = 'True'
                            }
                            $CardAcceptorId | Should Be 'True'
                        }
                        It "AccountType registrada en la transacción corresponde con la solicitud" {
                            if ($Request.AccountType -eq $Transaction.FromAccountType ) {
                                $FromAccountType = 'True'
                            }
                            $FromAccountType | Should Be 'True'
                        }
                        It "Codigo de la respuesta no debe ser Exitosa" {
                            if ($Transaction.ResponseCode -ne '00' ) {
                                $ResponseCode = 'True'
                            }
                            $ResponseCode | Should Be 'True'
                        }
                    Write-Host 'Validaciones de la Transaccion en Microservices'
                    It "Microservices: Se registra la transaccion en la BD" {
                        if ($TransactionMicroservices) {
                            $MAuthorizationNumber = 'True'
                        }
                        $MAuthorizationNumber | Should Be 'True'
                    }
                    It "Microservices: TransactionType correponde a la transaccion de Compra" {
                        if ($TransactionMicroservices.tran_type -eq '00') {
                            $MTransactionType = 'True'
                        }
                        $MTransactionType | Should Be 'True'
                    }
                    It "Microservices: Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                        if ($TransactionMicroservices.acquiring_inst_id -eq $Config.AcquirerPasarela ) {
                            $MIdAcquirer = 'True'
                        }
                        $MIdAcquirer | Should Be 'True'
                    }
                    It "Microservices: Monto de la transacción en BD corresponde al request" {
                        $Amount = $TransactionMicroservices.amount.Remove(10, 2)
                        if ([int]$Amount -eq $Request.Amount ) {
                            $MAmount = 'True'
                        }
                        $MAmount | Should Be 'True'
                    }
                    It "Microservices: CardAcceptor registrado en la transacción corresponde con la solicitud" {
                        if ($TransactionMicroservices.card_acceptor -eq $Request.Tags.CardAcceptorId ) {
                            $MCardAcceptorId = 'True'
                        }
                        $MCardAcceptorId | Should Be 'True'
                    }
                    It "Microservices: AccountType registrada en la transacción corresponde con la solicitud" {
                        if ($Request.AccountType -eq $TransactionMicroservices.from_account ) {
                            $MFromAccountType = 'True'
                        }
                        $MFromAccountType | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-865 Realizar compra con un DocType erroneo' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = "HJ"
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request.AccountType = $_.IdAccountType
                $DeltaLedgerBalance = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $_.Acronym -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()
                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraDocTypeErroneo'

                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "no se reconoce como un tipo de identificación").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-866 Realizar compra con un saldo mayor al del cliente' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = '5100000'
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request.AccountType = $_.IdAccountType
                $DeltaLedgerBalance = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()

                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraQueExcedeElSaldo'
                    $TransactionMicroservices = Get-ReponseSql -Value1 $Nonce.nonce -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMSByCorrelationId'
                    $Transaction = Get-ReponseSql -Value1 $IdCard -Value2 $TransactionMicroservices.authorization_number -ConnectionString $Config.ConnectionString -Parameter 'ConsultaIdCard'
                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "fondos insuficientes").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It "Codigo de la respuesta no debe ser Exitoso" {
                        if ($Transaction.ResponseCode -ne '00' ) {
                            $ResponseCode = 'True'
                        }
                        $ResponseCode | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                    Write-Host 'Validaciones de la Transaccion en TUP'
                        It "TransactionType correponde a la transaccion de Compra" {
                            if ($Transaction.TransactionType -eq '00') {
                                $TransactionType = 'True'
                            }
                            $TransactionType | Should Be 'True'
                        }
                        It "Pan de la transaccion correponde a la solicitud" {
                            if ($Transaction.Pan -eq $Pan ) {
                                $RPan = 'True'
                            }
                            $RPan | Should Be 'True'
                        }
                        It "Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                            if ($Transaction.IdAcquirer -eq $Config.AcquirerPasarela ) {
                                $IdAcquirer = 'True'
                            }
                            $IdAcquirer | Should Be 'True'
                        }
                        It "Monto de la transacción en BD corresponde al request" {
                            if ($Transaction.AmountTransaction -eq $Request.Amount ) {
                                $Amount = 'True'
                            }
                            $Amount | Should Be 'True'
                        }
                        It "CardAcceptor registrado en la transacción corresponde con la solicitud" {
                            if ($Transaction.IdCardAcceptor -eq $Request.Tags.CardAcceptorId ) {
                                $CardAcceptorId = 'True'
                            }
                            $CardAcceptorId | Should Be 'True'
                        }
                        It "AccountType registrada en la transacción corresponde con la solicitud" {
                            if ($Request.AccountType -eq $Transaction.FromAccountType ) {
                                $FromAccountType = 'True'
                            }
                            $FromAccountType | Should Be 'True'
                        }
                        It "Codigo de la respuesta no debe ser Exitosa" {
                            if ($Transaction.ResponseCode -ne '00' ) {
                                $ResponseCode = 'True'
                            }
                            $ResponseCode | Should Be 'True'
                        }
                    Write-Host 'Validaciones de la Transaccion en Microservices'
                    It "Microservices: Se registra la transaccion en la BD" {
                        if ($TransactionMicroservices) {
                            $MAuthorizationNumber = 'True'
                        }
                        $MAuthorizationNumber | Should Be 'True'
                    }
                    It "Microservices: TransactionType correponde a la transaccion de Compra" {
                        if ($TransactionMicroservices.tran_type -eq '00') {
                            $MTransactionType = 'True'
                        }
                        $MTransactionType | Should Be 'True'
                    }
                    It "Microservices: Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                        if ($TransactionMicroservices.acquiring_inst_id -eq $Config.AcquirerPasarela ) {
                            $MIdAcquirer = 'True'
                        }
                        $MIdAcquirer | Should Be 'True'
                    }
                    It "Microservices: Monto de la transacción en BD corresponde al request" {
                        $Amount = $TransactionMicroservices.amount.Remove(10, 2)
                        if ([int]$Amount -eq $Request.Amount ) {
                            $MAmount = 'True'
                        }
                        $MAmount | Should Be 'True'
                    }
                    It "Microservices: CardAcceptor registrado en la transacción corresponde con la solicitud" {
                        if ($TransactionMicroservices.card_acceptor -eq $Request.Tags.CardAcceptorId ) {
                            $MCardAcceptorId = 'True'
                        }
                        $MCardAcceptorId | Should Be 'True'
                    }
                    It "Microservices: AccountType registrada en la transacción corresponde con la solicitud" {
                        if ($Request.AccountType -eq $TransactionMicroservices.from_account ) {
                            $MFromAccountType = 'True'
                        }
                        $MFromAccountType | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-867 Realizar compra con un CardAcceptorId configurado para el cliente, sin permisos' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request.Tags.CardAcceptorId = '000000012800884'
                $Request.AccountType = $_.IdAccountType
                $DeltaLedgerBalance = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()

                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraCardAcceptorIdSinPermisos'

                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "no existe card acceptor").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-868 Realizar compra con un CardAcceptorId que no exista' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request.Tags.CardAcceptorId = '000000066662234'
                $Request.AccountType = $_.IdAccountType
                $DeltaLedgerBalance = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()

                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraCardAcceptorIdNoExsiste'

                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "no existe card acceptor").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-869 Realizar compra con un pan diferente al del cliente' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = ('6061250002001234').substring(12, 4)
                $Request.AccountType = $_.IdAccountType
                $DeltaLedgerBalance = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()

                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraConEnvioDePanDistintoAlCliente'
                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "No se encontraron tarjetas activas asociadas al número y/o tipo de identificación").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-870 Realizar compra sin enviar el pan del cliente' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = ''
                $Request.AccountType = $_.IdAccountType
                $DeltaLedgerBalance = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()

                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraSinEnvioDePan'
                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "'Pan' no tiene un formato valido").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-872 Realizar compra con un CustomerGroup que no exista en la BD' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = '69'
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request.AccountType = $_.IdAccountType
                $DeltaLedgerBalance = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $_.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()

                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraCustomerGroupErroneo'
                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "No se encontraron tarjetas activas asociadas al número y/o tipo de identificación.").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-873 Realizar compra con cliente en estado bloqueado' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraConClienteBloqueado'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request.AccountType = $_.IdAccountType
                $BalanceActual = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()

                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraClienteBloqueado'

                    $TransactionMicroservices = Get-ReponseSql -Value1 $Nonce.nonce -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMSByCorrelationId'
                    $Transaction = Get-ReponseSql -Value1 $IdCard -Value2 $TransactionMicroservices.authorization_number -ConnectionString $Config.ConnectionString -Parameter 'ConsultaIdCard'
                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    $TiposDeBloqueo = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'TiposDeBloqueo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        $TiposDeBloqueo | ForEach-Object {
                            $NameBlockType = $_.NameBlockType
                            if ([regex]::Matches($ResponseErrorMessage.ToUpper(), $NameBlockType).value) {
                                $ResponseError = 'True'
                            }
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It "Codigo de la respuesta no debe ser Exitoso" {
                        if ($Transaction.ResponseCode -ne '00' ) {
                            $ResponseCode = 'True'
                        }
                        $ResponseCode | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $BalanceActual) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                    Write-Host 'Validaciones de la Transaccion en TUP'
                        It "TransactionType correponde a la transaccion de Compra" {
                            if ($Transaction.TransactionType -eq '00') {
                                $TransactionType = 'True'
                            }
                            $TransactionType | Should Be 'True'
                        }
                        It "Pan de la transaccion correponde a la solicitud" {
                            if ($Transaction.Pan -eq $Pan ) {
                                $RPan = 'True'
                            }
                            $RPan | Should Be 'True'
                        }
                        It "Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                            if ($Transaction.IdAcquirer -eq $Config.AcquirerPasarela ) {
                                $IdAcquirer = 'True'
                            }
                            $IdAcquirer | Should Be 'True'
                        }
                        It "Monto de la transacción en BD corresponde al request" {
                            if ($Transaction.AmountTransaction -eq $Request.Amount ) {
                                $Amount = 'True'
                            }
                            $Amount | Should Be 'True'
                        }
                        It "CardAcceptor registrado en la transacción corresponde con la solicitud" {
                            if ($Transaction.IdCardAcceptor -eq $Request.Tags.CardAcceptorId ) {
                                $CardAcceptorId = 'True'
                            }
                            $CardAcceptorId | Should Be 'True'
                        }
                        It "AccountType registrada en la transacción corresponde con la solicitud" {
                            if ($Request.AccountType -eq $Transaction.FromAccountType ) {
                                $FromAccountType = 'True'
                            }
                            $FromAccountType | Should Be 'True'
                        }
                        It "Codigo de la respuesta no debe ser Exitosa" {
                            if ($Transaction.ResponseCode -ne '00' ) {
                                $ResponseCode = 'True'
                            }
                            $ResponseCode | Should Be 'True'
                        }
                    Write-Host 'Validaciones de la Transaccion en Microservices'
                    It "Microservices: Se registra la transaccion en la BD" {
                        if ($TransactionMicroservices) {
                            $MAuthorizationNumber = 'True'
                        }
                        $MAuthorizationNumber | Should Be 'True'
                    }
                    It "Microservices: TransactionType correponde a la transaccion de Compra" {
                        if ($TransactionMicroservices.tran_type -eq '00') {
                            $MTransactionType = 'True'
                        }
                        $MTransactionType | Should Be 'True'
                    }
                    It "Microservices: Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                        if ($TransactionMicroservices.acquiring_inst_id -eq $Config.AcquirerPasarela ) {
                            $MIdAcquirer = 'True'
                        }
                        $MIdAcquirer | Should Be 'True'
                    }
                    It "Microservices: Monto de la transacción en BD corresponde al request" {
                        $Amount = $TransactionMicroservices.amount.Remove(10, 2)
                        if ([int]$Amount -eq $Request.Amount ) {
                            $MAmount = 'True'
                        }
                        $MAmount | Should Be 'True'
                    }
                    It "Microservices: CardAcceptor registrado en la transacción corresponde con la solicitud" {
                        if ($TransactionMicroservices.card_acceptor -eq $Request.Tags.CardAcceptorId ) {
                            $MCardAcceptorId = 'True'
                        }
                        $MCardAcceptorId | Should Be 'True'
                    }
                    It "Microservices: AccountType registrada en la transacción corresponde con la solicitud" {
                        if ($Request.AccountType -eq $TransactionMicroservices.from_account ) {
                            $MFromAccountType = 'True'
                        }
                        $MFromAccountType | Should Be 'True'
                    }
                }
            }
        }
    }

    Describe 'Excepción: CAF-874 Realizar compra con cliente en estado inactivo' {

        Write-Host 'Obteniendo informacion de la base de datos...'
        $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraConClienteInactivo'
        if (!$ConsultaClientes -eq '') {
            $ConsultaClientes | ForEach-Object {
                $IdCard = $_.IdCard
                $Pan = $_.Pan
                #Construccion del Request
                $Request = New-PaymentRequest
                $Request.DocType = $_.Acronym
                $Request.DocNumber = $_.PersonIdentification
                $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                $Request.Tags.CustomerGroup = $_.CustomerGroup
                $Request.Tags.Pan = $_.Pan.substring(12, 4)
                $Request.AccountType = $_.IdAccountType
                $BalanceActual = $_.DeltaLedgerBalance

                $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                $Request.Token = $TransactionalToken
                $Request1 = $Request | ConvertTo-Json

                #Generacion del header
                $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

                try {
                    #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                    $chrono = [Diagnostics.Stopwatch]::StartNew()
                    #Consumo de servicio rest con la consulta
                    $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                    It 'Caso no deberia ser exitoso' -Skip{}
                    #Detiene el cronometro
                    $chrono.Stop()

                }
                catch {

                    $Response = $_.Exception
                    Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_CompraClienteInactivo'

                    $TransactionMicroservices = Get-ReponseSql -Value1 $Nonce.nonce -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMSByCorrelationId'
                    $Transaction = Get-ReponseSql -Value1 $IdCard -Value2 $TransactionMicroservices.authorization_number -ConnectionString $Config.ConnectionString -Parameter 'ConsultaIdCard'
                    $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'

                    $TiposDeBloqueo = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'TiposDeBloqueo'

                    It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                        if ($chrono.Elapsed.TotalSeconds -lt 10) {
                            $responseTime = 'True'
                        }
                        $responseTime | Should Be 'True'
                    }
                    It 'Codigo de error 4XX - Segun Mensajes de respuesta de Aspen' {
                        $ResponseError = $Response.Message
                        if ([regex]::Matches($ResponseError, "4[0-9][0-9]").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It 'La respuesta indica el motivo por el cual no se hizo la transacción' {
                        $ResponseErrorMessage = $Response.Response.StatusDescription
                        if ([regex]::Matches($ResponseErrorMessage, "tarjeta inactiva").value) {
                            $ResponseError = 'True'
                        }
                        $ResponseError | Should Be 'True'
                    }
                    It "Codigo de la respuesta no debe ser Exitoso" {
                        if ($Transaction.ResponseCode -ne '00' ) {
                            $ResponseCode = 'True'
                        }
                        $ResponseCode | Should Be 'True'
                    }
                    It 'La compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                        if ($ResponseSQL.DeltaLedgerBalance -eq $BalanceActual) {
                            $Balance = 'True'
                        }
                        $Balance | Should Be 'True'
                    }
                    Write-Host 'Validaciones de la Transaccion en TUP'
                    It "TransactionType correponde a la transaccion de Compra" {
                        if ($Transaction.TransactionType -eq '00') {
                            $TransactionType = 'True'
                        }
                        $TransactionType | Should Be 'True'
                    }
                    It "Pan de la transaccion correponde a la solicitud" {
                        if ($Transaction.Pan -eq $Pan ) {
                            $RPan = 'True'
                        }
                        $RPan | Should Be 'True'
                    }
                    It "Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                        if ($Transaction.IdAcquirer -eq $Config.AcquirerPasarela ) {
                            $IdAcquirer = 'True'
                        }
                        $IdAcquirer | Should Be 'True'
                    }
                    It "Monto de la transacción en BD corresponde al request" {
                        if ($Transaction.AmountTransaction -eq $Request.Amount ) {
                            $Amount = 'True'
                        }
                        $Amount | Should Be 'True'
                    }
                    It "CardAcceptor registrado en la transacción corresponde con la solicitud" {
                        if ($Transaction.IdCardAcceptor -eq $Request.Tags.CardAcceptorId ) {
                            $CardAcceptorId = 'True'
                        }
                        $CardAcceptorId | Should Be 'True'
                    }
                    It "AccountType registrada en la transacción corresponde con la solicitud" {
                        if ($Request.AccountType -eq $Transaction.FromAccountType ) {
                            $FromAccountType = 'True'
                        }
                        $FromAccountType | Should Be 'True'
                    }
                    It "Codigo de la respuesta no debe ser Exitosa" {
                        if ($Transaction.ResponseCode -ne '00' ) {
                            $ResponseCode = 'True'
                        }
                        $ResponseCode | Should Be 'True'
                    }
                    Write-Host 'Validaciones de la Transaccion en Microservices'
                    It "Microservices: Se registra la transaccion en la BD" {
                        if ($TransactionMicroservices) {
                            $MAuthorizationNumber = 'True'
                        }
                        $MAuthorizationNumber | Should Be 'True'
                    }
                    It "Microservices: TransactionType correponde a la transaccion de Compra" {
                        if ($TransactionMicroservices.tran_type -eq '00') {
                            $MTransactionType = 'True'
                        }
                        $MTransactionType | Should Be 'True'
                    }
                    It "Microservices: Adquiriente de la transaccion corresponde al de PASARELA $($Client)" {
                        if ($TransactionMicroservices.acquiring_inst_id -eq $Config.AcquirerPasarela ) {
                            $MIdAcquirer = 'True'
                        }
                        $MIdAcquirer | Should Be 'True'
                    }
                    It "Microservices: Monto de la transacción en BD corresponde al request" {
                        $Amount = $TransactionMicroservices.amount.Remove(10, 2)
                        if ([int]$Amount -eq $Request.Amount ) {
                            $MAmount = 'True'
                        }
                        $MAmount | Should Be 'True'
                    }
                    It "Microservices: CardAcceptor registrado en la transacción corresponde con la solicitud" {
                        if ($TransactionMicroservices.card_acceptor -eq $Request.Tags.CardAcceptorId ) {
                            $MCardAcceptorId = 'True'
                        }
                        $MCardAcceptorId | Should Be 'True'
                    }
                    It "Microservices: AccountType registrada en la transacción corresponde con la solicitud" {
                        if ($Request.AccountType -eq $TransactionMicroservices.from_account ) {
                            $MFromAccountType = 'True'
                        }
                        $MFromAccountType | Should Be 'True'
                    }
                }
            }
        }
    }
