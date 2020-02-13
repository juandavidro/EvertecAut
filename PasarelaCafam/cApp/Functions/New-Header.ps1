Function New-Header{
    param(
    [Parameter()]
    [string]$Token,

    [Parameter()]
    [string]$ContentType,

    [Parameter()]
    [string]$AppSecret,

    [Parameter()]
    [string]$AppKey
    )

    if($Token -and $ContentType){ #OPERCIONES QUE REQUIERAN CONTENT-TYPE EN SU CABECERA
        $Payload = @{epoch=Get-EpochTime
        nonce=New-Guid
        Token= "$Token"} #Token Generado en el Signin
        $secret= $AppSecret    #Secret es un campo de la tabla Apps de la base de datos de Aspen
        $Payload = $Payload | ConvertTo-Jwt -AppSecret $secret

        $Header = @{
        'X-PRO-Auth-App'= $AppKey
        'X-PRO-Auth-Payload'= $Payload
        'Content-Type'= "application/json"
        }
     }
     elseif($Token){ #OPERACIONES QUE NO REQUIERAN CONTEN-TYPE EN SU CABECERA
        $Payload = @{epoch=Get-EpochTime
        nonce=New-Guid
        Token= "$Token"} #Token Generado en el Signin
        $secret= $AppSecret    #Secret es un campo de la tabla Apps de la base de datos de Aspen
        $Payload = $Payload | ConvertTo-Jwt -AppSecret $secret

        $Header = @{
        'X-PRO-Auth-App'= $AppKey
        'X-PRO-Auth-Payload'= $Payload
        'Content-Type'= "application/json"
        }
    }
    else{ #METODO PARA OBTENER TOKEN CON SINGIN
        $Payload = @{epoch=Get-EpochTime
        nonce=New-Guid}
        $secret= $AppSecret    #Secret es un campo de la tabla Apps de la base de datos de Aspen
        $Payload = $Payload | ConvertTo-Jwt -AppSecret $secret

        $Header = @{
        'X-PRO-Auth-App'= $AppKey
        'X-PRO-Auth-Payload'= $Payload
        'Content-Type'= "application/json"
        }
    }
    return $Header
}