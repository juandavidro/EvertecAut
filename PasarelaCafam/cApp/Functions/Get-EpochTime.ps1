function Get-EpochTime{
    <#
    .SYNOPSIS
    Obtiene el número de segundos transcurridos desde ene-01-1970 00:00:00

    .DESCRIPTION
    Obtiene el número de segundos transcurridos desde ene-01-1970 00:00:00. Se conece también como la fecha Unix.

    .PARAMETER Subtract
    Tiempo que se debe restar del valor resultante. Si no se establece, no se resta ningún valor.

    .EXAMPLE
    Get-EpochTime
    Obtiene el número de segundos transcurridos desde ene-01-1970 00:00:00 hasta el momento de ejecución de la función.

    .EXAMPLE
    Get-EpochTime -Subtract (New-TimeSpan -Days -1)
    Obtiene el número de segundos transcurridos desde ene-01-1970 00:00:00 hasta el momento de ejecución de la función y resta un día.

    .LINK
    [Epoch & Unix Timestamp Conversion Tools](https://www.epochconverter.com/)

    .NOTES
    Author: atorres
    #>
    [CmdletBinding()]
    [OutputType([double])]
    Param
    (
        [Parameter()]
        [TimeSpan]
        $Subtract = [TimeSpan]::Zero
    )

    $Now = [DateTime]::UtcNow.AddMilliseconds($Subtract.TotalMilliseconds)
    $StartDate = [DateTime]::New(1970,1,1,0,0,0, [System.DateTimeKind]::Utc)
    $Difference = $Now - $StartDate
    [Math]::Round($Difference.TotalSeconds, 0) | Write-Output
}