function New-PaymentTransaction {
    param (
        [Parameter(Mandatory)]
        [String]
        $Token,

        [Parameter(Mandatory)]
        [int]
        $PaymentTest
    )

    switch ($PaymentTest) {
        1 {
            $Payments = @($null)

            $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraTipoIdentificacion'
            if (!$ConsultaClientes -eq '') {
                $ConsultaClientes | ForEach-Object {

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

                    #Generacion del header
                    $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                    $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret

                    try {
                        #Consumo de servicio rest con la consulta
                        $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                        $ResponseSQL = Get-ReponseSql -Value1 $_.IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                        $SRequest = @{
                            AuthNumber    = $Response.authNumber
                            TransactionId  = $Nonce.nonce
                            DocType        = $Request.DocType
                            DocNumber      = $Request.DocNumber
                            AccountType    = $Request.AccountType
                            Amount         = $Request.Amount
                            CustomerGroup  = $Request.Tags.CustomerGroup
                            CardAcceptorId = $Request.Tags.CardAcceptorId
                            Pan            = $Request.Tags.Pan
                            Balance        = $_.Balance
                            IdCard         = $_.IdCard
                            SaldoCompra    = $ResponseSQL.DeltaLedgerBalance
                        }
                        $Payments += $SRequest
                    }
                    catch {
                        Write-Host 'Error Compra: '$_.Exception.Response.StatusDescription
                        Write-Host $_.Exception
                    }
                }
            }
            else {
                $Payments += 'No hay clientes disponibles'
            }
        }
        2 {

            $Payments = @($null)

            $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
            if (!$ConsultaClientes -eq '') {
                $ConsultaClientes | ForEach-Object {
                    $ItemConsultas = $_
                    $IdCard = $_.IdCard
                    $Pan = $_.Pan
                    $DeltaLedgerBalance = $_.DeltaLedgerBalance
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

                        $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                        $Request.Token = $TransactionalToken
                        $Request.AccountType = $_.IdAccountType
                        $Request1 = $Request | ConvertTo-Json

                        #Generacion del header
                        $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                        $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret


                        try {
                            #Consumo de servicio rest con la consulta

                            $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                            $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                            $SRequest = @{
                                AuthNumber    = $Response.authNumber
                                TransactionId  = $Nonce.nonce
                                DocType        = $Request.DocType
                                DocNumber      = $Request.DocNumber
                                AccountType    = $Request.AccountType
                                Amount         = $Request.Amount
                                CustomerGroup  = $Request.Tags.CustomerGroup
                                CardAcceptorId = $Request.Tags.CardAcceptorId
                                Pan            = $Request.Tags.Pan
                                Balance        = $DeltaLedgerBalance
                                IdCard         = $IdCard
                                SaldoCompra    = $ResponseSQL.DeltaLedgerBalance

                            }
                            $Payments += $SRequest
                        }
                        catch {
                            Write-Host 'Error Compra: '$_.Exception.Response
                            Write-Host $_.Exception
                        }
                    }
                }
            }
            else {
                $Payments += 'No hay clientes disponibles'
            }
        }
        3 {
            $Payments = @($null)

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

                    $CardAcceptor = $Config.CardAcceptor
                    $CardAcceptor | ForEach-Object {

                        $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                        $Request.Token = $TransactionalToken
                        $Request.Tags.CardAcceptorId = $_
                        $Request1 = $Request | ConvertTo-Json

                        #Generacion del header
                        $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                        $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret


                        try {
                            #Consumo de servicio rest con la consulta
                            $BalanceActual = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                            $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                            $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'


                            $SRequest = @{
                                AuthNumber    = $Response.authNumber
                                TransactionId  = $Nonce.nonce
                                DocType        = $Request.DocType
                                DocNumber      = $Request.DocNumber
                                AccountType    = $Request.AccountType
                                Amount         = $Request.Amount
                                CustomerGroup  = $Request.Tags.CustomerGroup
                                CardAcceptorId = $Request.Tags.CardAcceptorId
                                Pan            = $Request.Tags.Pan
                                Balance        = $BalanceActual.DeltaLedgerBalance
                                IdCard         = $IdCard
                                SaldoCompra    = $ResponseSQL.DeltaLedgerBalance

                            }

                            $Payments += $SRequest
                        }
                        catch {
                            Write-Host 'Error Compra: '$_.Exception.Response
                            Write-Host $_.Exception
                        }
                    }
                }
            }
            else {
                $Payments += 'No hay clientes disponibles'
            }
        }
        4 {
            $Payments = @($null)

            $ConsultaClientes = Get-DataSql -ConnectionString $Config.ConnectionString -Parameter 'CompraCliente'
            if (!$ConsultaClientes -eq '') {
                $ConsultaClientes | ForEach-Object {
                    $ItemConsultas = $_
                    $IdCard = $_.IdCard
                    $Pan = $_.Pan
                    $DeltaLedgerBalance = $_.DeltaLedgerBalance
                    #Construccion del Request
                    $Request = New-PaymentRequest
                    $Request.DocType = $_.Acronym
                    $Request.DocNumber = $_.PersonIdentification
                    $Request.Amount = Get-Random -Minimum 20000 -Maximum 200000
                    $Request.Tags.CustomerGroup = $_.CustomerGroup
                    $Request.Tags.CardAcceptorId = $Config.CardAcceptor[1]
                    $Request.Tags.Pan = $_.Pan.substring(12, 4)

                    $TransactionalToken = Get-TransactionalToken -DocType $Request.DocType -DocNumber $Request.DocNumber -CustomerGroup $Request.Tags.CustomerGroup -Token $Token
                    $Request.Token = $TransactionalToken
                    $Request.AccountType = $_.IdAccountType
                    $Request1 = $Request | ConvertTo-Json

                    #Generacion del header
                    $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
                    $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret


                    try {
                            #Consumo de servicio rest con la consulta

                            $Response = Invoke-RestMethod -Method 'POST' -Uri $PathCompra -Headers $Header -Body $Request1
                            $ResponseSQL = Get-ReponseSql -Value1 $IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
                            $SRequest = @{
                                AuthNumber    = $Response.authNumber
                                TransactionId  = $Nonce.nonce
                                DocType        = $Request.DocType
                                DocNumber      = $Request.DocNumber
                                AccountType    = $Request.AccountType
                                Amount         = $Request.Amount
                                CustomerGroup  = $Request.Tags.CustomerGroup
                                CardAcceptorId = $Request.Tags.CardAcceptorId
                                Pan            = $Request.Tags.Pan
                                Balance        = $DeltaLedgerBalance
                                IdCard         = $IdCard
                                SaldoCompra    = $ResponseSQL.DeltaLedgerBalance

                            }
                            $Payments += $SRequest
                    }
                    catch {
                            Write-Host 'Error Compra: '$_.Exception.Response
                            Write-Host $_.Exception
                    }

                }
            }
            else {
                $Payments += 'No hay clientes disponibles'
            }
        }


        Default { }
    }

    return $Payments
}