Function Get-ReponseSql{
    Param(
            [string] $ConnectionString,
            [string] $Parameter,
            [string] $Value1,
            [string] $Value2
         )

    Import-Module PSProcessa

    $Path = Join-Path -Path $PSScriptRoot -ChildPath ('\Scripts\')
    $ResultDataRow = New-Object System.Collections.ArrayList
    $Consultas = New-Object System.Collections.ArrayList

    $ConsultasSQL = Get-Item -Path ($Path+$Client+'*Response*'+$Parameter+'.sql') | sort

        $ConsultasSQL.Name | ForEach-Object{
            $Consulta = Get-Content -Path ($Path+$PSItem) -Raw -Encoding Default
            $Consultas = $Consulta -f $Value1,$Value2
        }

        $Consultas | ForEach-Object{
            $ResultData = Invoke-SqlCommand -ConnectionString $ConnectionString -CommandText $PSItem
            $ResultDataRow = $ResultData
        }

    return $ResultDataRow
}