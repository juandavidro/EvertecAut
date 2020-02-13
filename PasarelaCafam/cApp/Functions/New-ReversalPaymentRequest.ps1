Function New-ReversalPaymentRequest {

<#
	.SYNOPSIS
        Retorna Hashtable con los campos necesarios para la solicitud de la transacci�n reverso de compra para pasarelas de pago.
    .DESCRIPTION
        Retorna Hashtable con los campos (TransactionId,DocType,DocNumber,AccountType,Amount,Tags) necesarios para la solicitud de anulaci�n de compra.
	.EXAMPLE
        New-ReversalPaymentRequest
    .NOTES
        Author:         JRojass
        Purpose/Change: Dise�o de automatizacion reverso de compra para pasarelas de pago.
#>

    [OutputType([object])]
    Param( )
    $req = @{
        TransactionId = 'TI'
        DocType       = '10000012186'
        DocNumber     = '80'
        AccountType   = '789485'
        Amount        = '1000000'
        Tags          =
        @{
            CustomerGroup  = '01'
            CardAcceptorId = '000000011029774'
            Pan            = '6061250021729581'
        }
    }
    return $Req
}