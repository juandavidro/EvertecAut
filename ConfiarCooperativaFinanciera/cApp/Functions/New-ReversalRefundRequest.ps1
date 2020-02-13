Function New-ReversalRefundRequest {

<#
	.SYNOPSIS
        Retorna Hashtable con los campos necesarios para la solicitud de la transacción reverso de compra para pasarelas de pago.
    .DESCRIPTION
        Retorna Hashtable con los campos (TransactionId,DocType,DocNumber,AccountType,Amount,Tags) necesarios para la solicitud de anulación de compra.
	.EXAMPLE
        New-ReversalRefundRequest
    .NOTES
        Author:         jcastro
        Creation Date:  07/05/2019
        Purpose/Change: Diseño de automatizacion reverso de anulación para pasarelas de pago.
#>

    [OutputType([object])]
    Param( )
    $req = @{
        TransactionId = New-Guid
        DocType       = '10000012186'
        DocNumber     = '80'
        AccountType   = '789485'
        Amount        = '1000000'
        Tags          =
        @{
            CardAcceptorId = '000000011029774'
        }
    }
    return $Req
}