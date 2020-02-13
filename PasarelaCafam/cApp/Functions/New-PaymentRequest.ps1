Function New-PaymentRequest {
<#
	.SYNOPSIS
        Retorna Hashtable con los campos del request de compra para pasarelas de pago.
    .DESCRIPTION
        Retorna Hashtable con los campos (DocType,DocNumber,AccountType,Token,Amount,Tags) del request de compra.
	.EXAMPLE
        New-PaymentRequest
    .NOTES
        Author:         JRojass
        Purpose/Change: Dise�o de automatizacion de compra para pasarelas de pago.
#>

    [OutputType([object])]
    Param( )
    $req = @{
        DocType='TI'
        DocNumber='10000012186'
        AccountType='80'
        Token='789485'
        Amount='1000000'
        Tags=
        @{
            CustomerGroup='01'
            CardAcceptorId= '000000011029774'
            Pan = '6061250021729581'
        }
    }
    return $Req
}