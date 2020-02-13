function Get-TransactionalToken {

     <#
	.SYNOPSIS
        Retorna el token transacional que es enviado al correo registrado por la persona que esta realizando la transacción.
    .DESCRIPTION
        Se realiza una petición a Mongo para obtener el contendio del mensaje que es enviado a la persona que realiza la transacción,
        luego se obtiene el código de 6 caracteres que es el token transaccional que retorna.
	.PARAMETER DocNumber
        Número de identificación de la persona que se quiere obtener el token transaccional
    .PARAMETER DocType
        Tipo de identficación de la persona que se quiere obtener el token transaccional
    .PARAMETER CustomerGroup
        CustomerGroup de la persona que se quiere  obtener el token transaccional
    .PARAMETER Token
		Token de autenticación
    .EXAMPLE
        Get-TransactionalToken -DocNumber 1022393657 -DocType 'TI' -CustomerGroup '01' -Token
    .NOTES
        Author:         JRojass
        Purpose/Change: Desarrollo de la función inicial
    #>

    param (
        [string]$DocType,
        [string]$DocNumber,
        [string]$CustomerGroup,
        [string]$Token
    )

    $Request = New-TokenRequest
    $Request.Tags.CustomerGroup = $CustomerGroup
    $Request.DocNumber = $DocNumber
    $Request.DocType = $DocType
    $Request1 = $Request | ConvertTo-Json
    try {
        $Header = New-Header -Token $Token -AppSecret $Config.AppSecret -AppKey $Config.AppKey
        $Nonce = $Header.'X-PRO-Auth-Payload' | ConvertFrom-Jwt -AppSecret $Config.AppSecret
        #Consumo de servicio rest con la consulta
        $Response = Invoke-RestMethod -Method 'POST' -Uri $PathSolicitudToken -Headers $Header -Body $Request1

        $Email = $null
        While([string]::IsNullOrEmpty($Email)){
            $Email = Get-KrakenMongo -DocType $DocType -DocNumber $DocNumber -CorrelationalId $Nonce.nonce
        }
        $MessageToken = [regex]::Matches($Email.Properties.Request.Message, "[0-9]{6}").value
    }
    catch {
        Write-Host 'Error Token Transaccional: '$_.Exception.Response.StatusDescription
        Write-Host $_.Exception
    }
    return $MessageToken
}