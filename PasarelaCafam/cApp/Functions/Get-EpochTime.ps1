function Get-EpochTime{
    <#
    .SYNOPSIS
    Obtiene el n�mero de segundos transcurridos desde ene-01-1970 00:00:00

    .DESCRIPTION
    Obtiene el n�mero de segundos transcurridos desde ene-01-1970 00:00:00. Se conece tambi�n como la fecha Unix.

    .PARAMETER Subtract
    Tiempo que se debe restar del valor resultante. Si no se establece, no se resta ning�n valor.

    .EXAMPLE
    Get-EpochTime
    Obtiene el n�mero de segundos transcurridos desde ene-01-1970 00:00:00 hasta el momento de ejecuci�n de la funci�n.

    .EXAMPLE
    Get-EpochTime -Subtract (New-TimeSpan -Days -1)
    Obtiene el n�mero de segundos transcurridos desde ene-01-1970 00:00:00 hasta el momento de ejecuci�n de la funci�n y resta un d�a.

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