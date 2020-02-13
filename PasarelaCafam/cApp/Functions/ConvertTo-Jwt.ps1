function ConvertTo-Jwt {
    <#
    .SYNOPSIS
    Crea un JWT con un payload a partir de los datos en _Payload_ o _InputObject_.

    .DESCRIPTION
    Crea un JWT con un payload a partir de los datos por el parámetro _Payload_ o _InputObject_, utilizando el algoritmo HMACSHA256.

    .PARAMETER Payload
    Datos que se deben serializar en el JWT.

    .PARAMETER InputObject
    Datos que se deben serializar en el JWT.

    .PARAMETER AppSecret
    La clave que se utiliza para firmar el JWT.

    .EXAMPLE
    $Secret = 'super-secret'
    $Content = @{
        Prop1 = 'abc'
        Prop2 = 1
        Prop3 = $true
    }
    $Content | ConvertTo-Jwt -AppSecret $Secret
    Obtiene el contenido cifrado con JWT.

    .INPUTS
    System.Collections.Generic.Dictionary[System.String, System.Object]
    El objeto puede ser recibido por canalización del parámetro _Payload_

    .INPUTS
    System.Management.Automation.PSObject
    El objeto puede ser recibido por canalización del parámetro _InputObject_

    .OUTPUTS
    System.String
    Contenido firmado con el secreto.

    .LINK
    [ConvertFrom-Jwt](ConvertFrom-Jwt.md)

    .LINK
    [About JWT in project site.](https://jwt.io/)
    
    .NOTES
    Author: atorres
    #>
    [CmdletBinding(DefaultParameterSetName='Hashtable')]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='Dictionary')]
        [System.Collections.Generic.Dictionary[string, object]]
        [ValidateNotNull()]
        $Payload,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='Hashtable')]
        [PSObject]
        [ValidateNotNull()]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='String')]
        [string]
        [ValidateNotNull()]
        $Value,

        [Parameter(Mandatory)]
        [string]
        [ValidateNotNullOrEmpty()]
        $AppSecret
    )

    if ($PSCmdlet.ParameterSetName -eq 'Hashtable') {
        $Payload = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,object]'
        $InputObject.GetEnumerator() | ForEach-Object {
            $Payload.Add($PSItem.Key.ToString(), $PSItem.Value)
        }
    }

    try {
        $Algorithm = [JWT.Algorithms.HMACSHA256Algorithm]::new();
        $Serializer = [JWT.Serializers.JsonNetSerializer]::New()
        $UrlEncoder = [JWT.JwtBase64UrlEncoder]::New()
        $Encoder  = [JWT.JwtEncoder]::new($Algorithm, $Serializer, $UrlEncoder)
        $Encoder.Encode($Payload, $AppSecret) | Write-Output
    }
    catch {
        throw
    }
}
