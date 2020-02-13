function ConvertFrom-Jwt {
    <#
    .SYNOPSIS
    Dado un contenido en formato JWT, lo decodifica y devuelve la carga JSON.

    .DESCRIPTION
    Dado un contenido en formato JWT, lo decodifica y devuelve el payload en formato JSON.

    .PARAMETER Content
    Contenido en formato JWT.

    .PARAMETER AppSecret
    La clave que se utilizó para firmar el JWT.

    .EXAMPLE
    $Secret = 'super-secret'
    $Content = @{
        Prop1 = 'abc'
        Prop2 = 1
        Prop3 = $true
    }
    ($Content | ConvertTo-Jwt -AppSecret $Secret) | ConvertFrom-Jwt -AppSecret $Secret
    Obtiene el diccionario de datos en claro, previamente cifrado con JWT

    .INPUTS
    System.String
    Cadena de texto que representa el contenido en formato JWT.
    El objeto puede ser recibido por canalización del parámetro _Content_

    .OUTPUTS
    System.Management.Automation.PSObject
    Representa los datos deserializados del contenido JWT.
    
    .LINK
    [ConvertTo-Jwt](ConvertTo-Jwt.md)

    .LINK
    [About JWT in project site.](https://jwt.io/)

    .NOTES
    Author: atorres
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Content,

        [Parameter(Mandatory)]
        [string]
        $AppSecret
    )

    try {
        $Serializer = [JWT.Serializers.JsonNetSerializer]::New()
        $Provider = [JWT.UtcDateTimeProvider]::new()
        $Validator = [JWT.JwtValidator]::new($Serializer, $Provider)
        $UrlEncoder = [JWT.JwtBase64UrlEncoder]::New()
        $Decoder = [JWT.JwtDecoder]::New($Serializer, $Validator, $UrlEncoder)
        $Decoder.Decode($Content, $AppSecret, $true) | ConvertFrom-Json | Write-Output
    }
    catch {
        throw
    }
}