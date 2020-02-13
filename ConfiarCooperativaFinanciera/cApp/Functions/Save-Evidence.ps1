Function Save-Evidence{

    <#
	.SYNOPSIS
        Genera y almacena las evidencias caso de prueba.
    .DESCRIPTION
        Genera y almacena las evidencias apartir de la ejecucion de cada caso de prueba en el directorio de evidencias del proyecto.
    .PARAMETER Request
        Objeto de tipo Hashtable que contiene los datos de la solicitud con la que se consume el servicio.
    .PARAMETER Response
        Objeto de tipo PSCustomObject que contiene la respuesta como resultado de consumir el servicio.
    .PARAMETER Value1
        Valor que sera incluido en el nombre del archivo de evidencia.
    .PARAMETER Value2
        Valor que sera incluido en el nombre del archivo de evidencia.
    .PARAMETER Value3
        Valor que sera incluido en el nombre del archivo de evidencia.
    .PARAMETER PathEvidencias
        Ruta en la que se almacenara la evidencia.
    .PARAMETER Testtype
        Tipo de prueba que se esta ejecutando puede ser de Exito, Robustez, Excepcion, Validacion de Campo, etc. Incluido en el nombre del archivo.
    .EXAMPLE
        Save-Evidence -Request $Request -Response $Response -Value1 $Parameter -Value2 $Description -PathEvidencias $PathEvidencias -Testtype 'ValidacionCampos'
    .NOTES
        Author:         jcastro
        Creation Date:  03/05/2019
        Purpose/Change:
#>

    param(
    [Parameter(Mandatory=$true)]
    [Hashtable]$Request,

    [Parameter(Mandatory=$true)]
    [PSCustomObject]$Response,

    [Parameter()]
    [string]$Value1,

    [Parameter()]
    [string]$Value2,

    [Parameter()]
    [string]$Value3,

    [Parameter(Mandatory=$true)]
    [string]$PathEvidencias,

    [Parameter(Mandatory=$true)]
    [string]$Testtype

    )

    '####  Request  ####' | Out-File (Join-Path $PathEvidencias -ChildPath ('{2}{3}_{0}-{1}.txt' -f ($Value1,$Value2,$Testtype,$Value3))) -Append
    $Request | Out-File (Join-Path $PathEvidencias -ChildPath ('{2}{3}_{0}-{1}.txt' -f ($Value1,$Value2,$Testtype,$Value3))) -Append

    '####  Response  ####' | Out-File (Join-Path $PathEvidencias -ChildPath ('{2}{3}_{0}-{1}.txt' -f ($Value1,$Value2,$Testtype,$Value3))) -Append
    $Response | Out-File (Join-Path $PathEvidencias -ChildPath ('{2}{3}_{0}-{1}.txt' -f ($Value1,$Value2,$Testtype,$Value3))) -Append
}