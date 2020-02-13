function New-RefundPaymentTransaction {

    <#
	.SYNOPSIS
        Genera anulaciones de compra para ser reversadas.
    .DESCRIPTION
        Ejecuta el procedimiento que genera las compras, para luego anularlas.Retorna la información de las transacciones de anulacion en un array.
    .PARAMETER Token
        String con token de autenticación
    .PARAMETER PaymentTest
        Prueba de la cual se desea generar datos. Revisar función New-PaymentTransaction.
    .EXAMPLE
        New-RefundPaymentTransaction -Token 'yysdasdsadas4545645weq4r65t4ytr45gf64hfg6h4fgh654fg' -PaymentTest 1
    .NOTES
        Author:         jcastro
        Creation Date:  07/05/2019
        Purpose/Change: Diseño de automatizacion reverso de anulación para pasarelas de pago.
#>
    param(
        [Parameter(Mandatory)]
        [String]
        $Token,

        [Parameter(Mandatory)]
        [int]
        $PaymentTest
    )

    $Refunds = @($null)
    Write-Host 'Generando compras para anular...'
    $Payments = New-PaymentTransaction -Token $Token -PaymentTest $PaymentTest
    Write-Host 'Compras generadas...'
    Write-Host 'Generando anulaciones de compras...'
    $Payments.Where( { $_ -ne $null }) | ForEach-Object {
        #Construccion del Request
        $Request = New-RefundPaymentRequest
        $Request.AuthNumber = $_.AuthNumber
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
        $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret
        try {
            $Response = Invoke-RestMethod -Method 'POST' -Uri $PathAnulacionCompra -Headers $Header -Body $Request1
            $ResponseSQL = Get-ReponseSql -Value1 $_.IdCard -Value2 $Request.AccountType -ConnectionString $Config.ConnectionString -Parameter 'ConsultaSaldo'
            $SRequest = @{
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
            $Refunds += $SRequest
        }
        catch {
            Write-Host 'Error Compra: '$_.Exception.Response
            Write-Host $_.Exception
        }
    }
    Write-Host 'Anulaciones generadas...'
    return $Refunds
}

