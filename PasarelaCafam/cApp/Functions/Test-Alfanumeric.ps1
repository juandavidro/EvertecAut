Function Test-Alfanumeric {
    <#
	.SYNOPSIS
        Retorna Array de pruebas de validación de un parámetro de comando de servicio RabbitMQ.
    .DESCRIPTION
        Crea un Array de objetos (Parameter,Value,Description) asignando valores inválidos al parámetro $ParameterName
	.PARAMETER ParameterName
		Nombred del parámetro a validar.
	.PARAMETER MinLength
		Mínima longitud permitida para el valor del parámetro.
	.PARAMETER MaxLength
        Máxima longitud permitida para el valor del parámetro.
	.PARAMETER Nullable
        Si el parámetro está presente, se omite la prueba de validación para parámetro nulo.
    .EXAMPLE
        Test-Parameter -ParameterName 'AccountNumber' -MinLength 13 -MaxLength 23
    .NOTES
        Author:         jespitia
        Creation Date:  17/04/2017
        Purpose/Change: Desarrollo de la función inicial
#>
    [CmdletBinding()]
    [OutputType([System.Array])]
    Param(
        [string] $ParameterName,
        [int] $MinLength,
        [int] $MaxLength,
        [Switch] $Nullable
    )

    $Cases = @($null)

    if (!$Nullable.IsPresent) {
        $Cases += @{ Parameter = $ParameterName; Value = $null; Description = "es nulo" }
        $Cases += @{ Parameter = $ParameterName; Value = [string]::Empty; Description = "es vacio" }
        $Cases += @{ Parameter = $ParameterName; Value = '  '; Description = "esta definido solo por espacios en blanco" }
    }
    $Cadena = '0123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354550123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354551323334353637383940414243444546474849505152535455'

    if ($PSBoundParameters.ContainsKey('MinLength')) {
        $Cases += @{ Parameter = $ParameterName; Value = ($Cadena).Substring(1,$MinLength-1); Description = "tiene una longitud menor que $MinLength caracteres" }
    }

    if ($PSBoundParameters.ContainsKey('MaxLength')) {
        $Cases += @{ Parameter = $ParameterName; Value = ($Cadena).Substring(1,$MaxLength+1); Description = "tiene una longitud mayor que $MaxLength caracteres" }
    }


    $Cases | Write-Output
}