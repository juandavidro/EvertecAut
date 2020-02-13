Function New-TokenRequest {

<#
	.SYNOPSIS
        Retorna Hashtable con los campos necesarios para la solicitud de token transaccional para pasarelas de pago.
    .DESCRIPTION
        Retorna Hashtable con los campos (TransactionId,DocType,DocNumber,AccountType,Amount,Tags) necesarios para la solicitud de token transaccional.
	.EXAMPLE
        New-TokenRequest
    .NOTES
        Author:         JRojass
        Purpose/Change: Dise�o de automatizacion de token transaccional para pasarelas de pago.
#>

    [OutputType([object])]
    Param( )
    $req = @{
        DocType='TI'
        DocNumber='10000012186'
        Tags=
        @{
            CustomerGroup='01'
        }
    }
    return $Req
}