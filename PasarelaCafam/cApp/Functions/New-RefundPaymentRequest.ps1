Function New-RefundPaymentRequest {

    <#
	.SYNOPSIS
        Retorna Hashtable con los campos necesarios para la solicitud de la transacci�n anulaci�n de compra para pasarelas de pago.
    .DESCRIPTION
        Retorna Hashtable con los campos (AuthNumber,DocType,DocNumber,AccountType,Amount,Tags) necesarios para la solicitud de anulaci�n de compra.
	.EXAMPLE
        New-RefundPaymentRequest
    .NOTES
        Author:         JRojass
        Purpose/Change: Dise�o de automatizacion anulaci�n de compra para pasarelas de pago.
#>

    [OutputType([object])]
    Param( )
    $req = @{
        AuthNumber  = '236584'
        DocType     = 'CC'
        DocNumber   = '10000012186'
        AccountType = '80'
        Amount      = '1000000'
        Tags=
        @{
            CardAcceptorId= '000000011029774'
        }
    }
    return $Req
}