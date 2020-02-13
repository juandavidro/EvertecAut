$ChildPath = '\Evidencias\'+ $Client+'\ReversoCompra'
$PathEvidencias = Join-Path $PSScriptRoot -ChildPath $ChildPath #Ruta donde se almacenan las evidencias
if (Test-Path -Path $PathEvidencias ) {
}
else {
    New-Item -Path $PathEvidencias -ItemType Directory
}

$ParameterToken = 'Pasarela_' + $Client
$Token = Get-AuthenticationToken -Parameter $ParameterToken

Describe 'Validacion de parametros invalidos' {


    Write-Host 'Generando compra para reversar'
    $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
    Write-Host 'Compra generada'

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
            #Construccion del Request
            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $Payments[1].TransactionId
            $Request.DocType = $Payments[1].DocType
            $Request.DocNumber = $Payments[1].DocNumber
            $Request.AccountType = $Payments[1].AccountType
            $Request.Amount = $Payments[1].Amount
            $Request.Tags.CustomerGroup = $Payments[1].CustomerGroup
            $Request.Tags.CardAcceptorId = $Payments[1].CardAcceptorId
            $Request.Tags.Pan = $Payments[1].Pan
            #Asigna el valor del parametro a probar
            $Request.($_.Parameter) = $_.Value
            $Request1 = $Request | ConvertTo-Json

            #Invoca la función que genera el Header para consumir el servicio Rest
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {

                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                #Detiene el cronometro
                $chrono.Stop()
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




    Write-Host 'Generando compras para reversar'
    $Payments = New-PaymentTransaction -Token $Token -PaymentTest 1
    Write-Host 'Compras generadas'
    $Payments.Where( { $_ -ne $null }) | ForEach-Object {
        #$TransactionMongo = Get-DataMongo -Value1 $Config.Channel -Value2 $_ -Parameter 'QueryReversoTipos'
        Describe "CAF-875: Reverso de compra Casos Exito, Todos los tipos de identificación: $($_.DocType)-$($_.DocNumber)" {

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                #Detiene el cronometro
                $chrono.Stop()

                Write-Host $chrono.Elapsed.TotalSeconds
                $TransactionMicroservices = Get-ReponseSql -Value1 $_.TransactionId -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMicroservicesReverso'
                $ResponseSQL = Get-ReponseSql -Value1 $_.IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                $Transaction = Get-ReponseSql -Value1 $_.IdCard -Value2 $TransactionMicroservices.ret_reference_number -ConnectionString $Config.ConnectionString -Parameter 'ConsultaTRXReference'

                $SRequest = @{
                    TransactionIdOriginal = $Request.TransactionId
                    DocType               = $Request.DocType
                    DocNumer              = $Request.DocNumber
                    AccountType           = $Request.AccountType
                    Amount                = $Request.Amount
                    CustomerGroup         = $Request.Tags.CustomerGroup
                    CardAcceptorId        = $Request.Tags.CardAcceptorId
                    Pan                   = $Request.Tags.Pan
                    SaldoCompra           = $_.SaldoCompra
                    SaldoReverso          = $ResponseSQL.DeltaLedgerBalance
                }

                #Invoca la función que almacena la evidencia del caso
                Save-Evidence -Request $SRequest -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Exito'

                It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                    if ($chrono.Elapsed.TotalSeconds -lt 10) {
                        $responseTime = 'True'
                    }
                    $responseTime | Should Be 'True'
                }
                Write-Host 'Validaciones de la Transaccion en TUP'
                It "Se registra la transaccion en la BD" {
                    if (![string]::IsNullOrEmpty($Transaction.AuthorizationNumber)) {
                        $RAuthorizationNumber = 'True'
                    }
                    $RAuthorizationNumber | Should Be 'True'
                }
                It "MessageType correponde con un Reverso" {
                    if ($Transaction.MessageType -eq '0420') {
                        $MessageType = 'True'
                    }
                    $MessageType | Should Be 'True'
                }
                It "TransactionType correponde a la transaccion de Compra" {
                    if ($Transaction.TransactionType -eq '00') {
                        $TransactionType = 'True'
                    }
                    $TransactionType | Should Be 'True'
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
                    if (![string]::IsNullOrEmpty($TransactionMicroservices.original_correlation_id)) {
                        $MAuthorizationNumber = 'True'
                    }
                    $MAuthorizationNumber | Should Be 'True'
                }
                It "Microservices: Message Type correponde a la transaccion de Compra" {
                    if ($TransactionMicroservices.message_type -eq '0420') {
                        $message_type = 'True'
                    }
                    $message_type | Should Be 'True'
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
                It 'Se retorna el valor de la compra al saldo del cliente' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $_.Balance) {
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




    Write-Host 'Generando compras para reversar'
    $Payments = New-PaymentTransaction -Token $Token -PaymentTest 2
    Write-Host 'Compras generadas'
    $Payments.Where( { $_ -ne $null }) | ForEach-Object {
        #$TransactionMongo = Get-DataMongo -Value1 $Config.Channel -Value2 $_ -Parameter 'QueryReversoTipos'
        Describe "CAF-874: Reverso de compra Casos Exito, con los bolsillos (80, 81, 82 y 83): $($_.DocType)-$($_.DocNumber)" {

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                #Detiene el cronometro
                $chrono.Stop()

                Write-Host $chrono.Elapsed.TotalSeconds
                $TransactionMicroservices = Get-ReponseSql -Value1 $_.TransactionId -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMicroservicesReverso'
                $ResponseSQL = Get-ReponseSql -Value1 $_.IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                $Transaction = Get-ReponseSql -Value1 $_.IdCard -Value2 $TransactionMicroservices.ret_reference_number -ConnectionString $Config.ConnectionString -Parameter 'ConsultaTRXReference'

                $SRequest = @{
                    TransactionIdOriginal = $Request.TransactionId
                    DocType               = $Request.DocType
                    DocNumer              = $Request.DocNumber
                    AccountType           = $Request.AccountType
                    Amount                = $Request.Amount
                    CustomerGroup         = $Request.Tags.CustomerGroup
                    CardAcceptorId        = $Request.Tags.CardAcceptorId
                    Pan                   = $Request.Tags.Pan
                    SaldoCompra           = $_.SaldoCompra
                    SaldoReverso          = $ResponseSQL.DeltaLedgerBalance
                }

                #Invoca la función que almacena la evidencia del caso
                Save-Evidence -Request $SRequest -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -Value3 $Request.AccountType -PathEvidencias $PathEvidencias -Testtype 'Exito_TodosBolsillos_'

                It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                    if ($chrono.Elapsed.TotalSeconds -lt 10) {
                        $responseTime = 'True'
                    }
                    $responseTime | Should Be 'True'
                }
                Write-Host 'Validaciones de la Transaccion en TUP'
                It "Se registra la transaccion en la BD" {
                    if (![string]::IsNullOrEmpty($Transaction.AuthorizationNumber)) {
                        $RAuthorizationNumber = 'True'
                    }
                    $RAuthorizationNumber | Should Be 'True'
                }
                It "MessageType correponde con un Reverso" {
                    if ($Transaction.MessageType -eq '0420') {
                        $MessageType = 'True'
                    }
                    $MessageType | Should Be 'True'
                }
                It "TransactionType correponde a la transaccion de Compra" {
                    if ($Transaction.TransactionType -eq '00') {
                        $TransactionType = 'True'
                    }
                    $TransactionType | Should Be 'True'
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
                    if (![string]::IsNullOrEmpty($TransactionMicroservices.original_correlation_id)) {
                        $MAuthorizationNumber = 'True'
                    }
                    $MAuthorizationNumber | Should Be 'True'
                }
                It "Microservices: Message Type correponde a la transaccion de Compra" {
                    if ($TransactionMicroservices.message_type -eq '0420') {
                        $message_type = 'True'
                    }
                    $message_type | Should Be 'True'
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
                It 'Se retorna el valor de la compra al saldo del cliente' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $_.Balance) {
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




    Write-Host 'Generando compras para reversar'
    $Payments = New-PaymentTransaction -Token $Token -PaymentTest 3
    Write-Host 'Compras generadas'
    $Payments.Where( { $_ -ne $null }) | ForEach-Object {
        #$TransactionMongo = Get-DataMongo -Value1 $Config.Channel -Value2 $_ -Parameter 'QueryReversoTipos'
        Describe "CAF-873: Reverso de compra Casos Exito, con los CardAcceptorId configurados: $($_.DocType)-$($_.DocNumber)" {

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                #Detiene el cronometro
                $chrono.Stop()

                Write-Host $chrono.Elapsed.TotalSeconds
                $TransactionMicroservices = Get-ReponseSql -Value1 $_.TransactionId -ConnectionString $Config.ConnectionStringMicroservice -Parameter 'ConsultaMicroservicesReverso'
                $ResponseSQL = Get-ReponseSql -Value1 $_.IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                $global:ResponseSqlActual = $ResponseSQL.DeltaLedgerBalance
                $Transaction = Get-ReponseSql -Value1 $_.IdCard -Value2 $TransactionMicroservices.ret_reference_number -ConnectionString $Config.ConnectionString -Parameter 'ConsultaTRXReference'

                $SRequest = @{
                    TransactionIdOriginal = $Request.TransactionId
                    DocType               = $Request.DocType
                    DocNumer              = $Request.DocNumber
                    AccountType           = $Request.AccountType
                    Amount                = $Request.Amount
                    CustomerGroup         = $Request.Tags.CustomerGroup
                    CardAcceptorId        = $Request.Tags.CardAcceptorId
                    Pan                   = $Request.Tags.Pan
                    SaldoCompra           = $_.SaldoCompra
                    SaldoReverso          = $ResponseSQL.DeltaLedgerBalance
                }

                #Invoca la función que almacena la evidencia del caso
                Save-Evidence -Request $SRequest -Response $Response -Value1 $Request.DocType -Value2 $Request.DocNumber -Value3 $Request.Tags.CardAcceptorId -PathEvidencias $PathEvidencias -Testtype 'Exito_CardAcceptorId_'

                It 'Tiempo de respuesta a la solicitud debe ser inferior a 10 seg' {
                    if ($chrono.Elapsed.TotalSeconds -lt 10) {
                        $responseTime = 'True'
                    }
                    $responseTime | Should Be 'True'
                }
                Write-Host 'Validaciones de la Transaccion en TUP'
                It "Se registra la transaccion en la BD" {
                    if (![string]::IsNullOrEmpty($Transaction.AuthorizationNumber)) {
                        $RAuthorizationNumber = 'True'
                    }
                    $RAuthorizationNumber | Should Be 'True'
                }
                It "MessageType correponde con un Reverso" {
                    if ($Transaction.MessageType -eq '0420') {
                        $MessageType = 'True'
                    }
                    $MessageType | Should Be 'True'
                }
                It "TransactionType correponde a la transaccion de Compra" {
                    if ($Transaction.TransactionType -eq '00') {
                        $TransactionType = 'True'
                    }
                    $TransactionType | Should Be 'True'
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
                    if (![string]::IsNullOrEmpty($TransactionMicroservices.original_correlation_id)) {
                        $MAuthorizationNumber = 'True'
                    }
                    $MAuthorizationNumber | Should Be 'True'
                }
                It "Microservices: Message Type correponde a la transaccion de Compra" {
                    if ($TransactionMicroservices.message_type -eq '0420') {
                        $message_type = 'True'
                    }
                    $message_type | Should Be 'True'
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

    Write-Host 'Validaciones en la Base de Datos'
    It 'Se retorna el valor de la compra al saldo del cliente' {
        if ($ResponseSqlActual -eq $Payments[1].Balance) {
            $Balance = 'True'
        }
        $Balance | Should Be 'True'
    }






    Describe 'Excepcion: CAF-865 Realizar reverso de compra con un DocType erroneo' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = "HJ"
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $DeltaLedgerBalance = $_.SaldoCompra
            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraDocTypeErroneo'

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
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }

    }

    Describe 'Excepcion: CAF-866 Realizar reverso de compra con un valor de transacción distinto al original' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = Get-Random -Minimum 1000000 -Maximum 1000500
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $DeltaLedgerBalance = $_.SaldoCompra

            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
            $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraQueExcedeElSaldo'
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
                    if ([regex]::Matches($ResponseErrorMessage, "No se encontró una transacción con el identificador").value) {
                        $ResponseError = 'True'
                    }
                    $ResponseError | Should Be 'True'
                }
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }

            }
        }
    }

    Describe 'Excepcion: CAF-867 Realizar reverso de compra con un CardAcceptorId configurado para el cliente, sin permisos' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = '000000012800884'
            $Request.Tags.Pan = $_.Pan
            $DeltaLedgerBalance = $_.SaldoCompra

            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraCardAcceptorIdSinPermisos'

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
                    if ([regex]::Matches($ResponseErrorMessage, "No se encontró una transacción con el identificador").value) {
                        $ResponseError = 'True'
                    }
                    $ResponseError | Should Be 'True'
                }
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }
    }

    Describe 'Excepcion: CAF-868 Realizar reverso de compra con un CardAcceptorId que no exista' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = '000000066662234'
            $Request.Tags.Pan = $_.Pan
            $DeltaLedgerBalance = $_.SaldoCompra

            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraCardAcceptorIdNoExsiste'

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
                    if ([regex]::Matches($ResponseErrorMessage, "No se encontró una transacción con el identificador").value) {
                        $ResponseError = 'True'
                    }
                    $ResponseError | Should Be 'True'
                }
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }
    }

    Describe 'Excepcion: CAF-869 Realizar reverso de compra con un pan diferente al del cliente' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = ('6061250002001234').substring(12, 4)
            $DeltaLedgerBalance = $_.SaldoCompra
            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraConEnvioDePanDistintoAlCliente'
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
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }
    }

    Describe 'Excepcion: CAF-870 Realizar reverso de compra sin enviar el pan del cliente' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = ''
            $DeltaLedgerBalance = $_.SaldoCompra
            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraSinEnvioDePan'
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
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }
    }

    Describe 'Excepcion: CAF-872 Realizar reverso de compra con un CustomerGroup que no exista en la BD' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = '69'
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $DeltaLedgerBalance = $_.SaldoCompra

            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraCustomerGroupErroneo'
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
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }
    }

    Describe 'Excepcion: CAF-872 Realizar reverso de compra con un TransactionId que no existe' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = new-guid
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $DeltaLedgerBalance = $_.SaldoCompra

            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraTransactionIdNoExsiste'
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
                    if ([regex]::Matches($ResponseErrorMessage, "No se encontró una transacción con el identificador.").value) {
                        $ResponseError = 'True'
                    }
                    $ResponseError | Should Be 'True'
                }
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }
    }

    Describe 'Excepcion: CAF-872 Realizar reverso de compra con un DocNumber diferente al del cliente' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = '1022345123'
            $Request.AccountType = $_.AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $DeltaLedgerBalance = $_.SaldoCompra

            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraDocNumberDiferente'
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
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }
    }

    Describe 'Excepcion: CAF-872 Realizar reverso de compra con un Bolsillo diferente al del cliente' {

        Write-Host 'Generando compra para reversar'
        $Payments = New-PaymentTransaction -Token $Token -PaymentTest 4
        Write-Host 'Compra generada'

        $Payments.Where( { $_ -ne $null }) | ForEach-Object {
            $IdCard = $_.IdCard
            $Pan = $_.Pan

            #Función que retorna un bolsiilo diferente al de la compra
            $Array = ("80", "81", "82" , "83")
            $AccountType = $_.AccountType
            $NewAccountType = [array]::indexof($Array, $AccountType)
            if ($NewAccountType -eq 3) {
                $NewAccountType = 1
            }
            $AccountType = $Array[$NewAccountType + 1]

            #Construccion del Request
            $Request = New-ReversalPaymentRequest
            $Request.TransactionId = $_.TransactionId
            $Request.DocType = $_.DocType
            $Request.DocNumber = $_.DocNumber
            $Request.AccountType = $AccountType
            $Request.Amount = $_.Amount
            $Request.Tags.CustomerGroup = $_.CustomerGroup
            $Request.Tags.CardAcceptorId = $_.CardAcceptorId
            $Request.Tags.Pan = $_.Pan
            $DeltaLedgerBalance = $_.SaldoCompra

            $Request1 = $Request | ConvertTo-Json

            #Generacion del header
            $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey

            try {
                #Inicia el cronometro que calculara el tiempo en que responde el servicio a la personalización
                $chrono = [Diagnostics.Stopwatch]::StartNew()
                #Consumo de servicio rest con la consulta
                $Response = Invoke-RestMethod -Method 'PATCH' -Uri $PathReversoCompra -Headers $Header -Body $Request1
                It 'Caso no deberia ser exitoso' -Skip{}
                #Detiene el cronometro
                $chrono.Stop()
            }
            catch {

                $Response = $_.Exception
                Save-Evidence -Request $Request -Response $Response.Response -Value1 $Request.DocType -Value2 $Request.DocNumber -PathEvidencias $PathEvidencias -Testtype 'Excepción_ReversoCompraBolsilloDistinto'
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
                It 'El reverso de compra no afecta el saldo de la tarjeta correspondiente al monto de la transacción' {
                    if ($ResponseSQL.DeltaLedgerBalance -eq $DeltaLedgerBalance) {
                        $Balance = 'True'
                    }
                    $Balance | Should Be 'True'
                }
            }
        }
    }



