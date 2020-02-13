Function Save-Token {
    <#
	.SYNOPSIS
        Crea un archivo con el token de autenticacion generado.
    .DESCRIPTION
        Crea un archivo con el token de autenticacion generado.
    .PARAMETER Value1
        jti generado apartir de la deserializacion del JWT.
    .PARAMETER Value2
        Fecha expericacion generado apartir de la deserializacion del JWT.
    .PARAMETER PathToken
        Ruta local en la que se almacenara el archivo con la informacion del token.
    .PARAMETER Testtype
        Nombre con el que se generara el archivo.
    .EXAMPLE
        Save-Token -Value1 $DecodeJWT.jti -Value2 $DecodeJWT.exp -PathToken $PathToken -Testtype $SaveToken
    .NOTES
        Author:         jpena
        Creation Date:  03/05/2019
        Purpose/Change:
#>

    param(

        [Parameter()]
        [string]$Value1,

        [Parameter()]
        [string]$Value2,


        [Parameter(Mandatory = $true)]
        [string]$PathToken,

        [Parameter(Mandatory = $true)]
        [string]$Testtype

    )

    $Value1, $Value2 | Out-File (Join-Path $PathToken -ChildPath ('{2}.txt' -f ($Value1, $Value2, $Testtype))) -Encoding UTF8

}