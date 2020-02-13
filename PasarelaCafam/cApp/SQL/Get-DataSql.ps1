Function Get-DataSql {
    Param(
        [string] $ConnectionString,
        [string] $Parameter
    )

    Import-Module PSProcessa

    $Path = Join-Path -Path $PSScriptRoot -ChildPath ('\Scripts\')
    $ResultDataRow = New-Object System.Collections.ArrayList
    $Consultas = New-Object System.Collections.ArrayList

    $ConsultasSQL = Get-Item -Path ($Path + $Client + 'Request*' + $Parameter + '*.sql') | sort

    $ConsultasSQL.Name | ForEach-Object {
        $Consulta = Get-Content -Path ($Path + $PSItem) -Raw -Encoding Default
        $Consultas = $Consulta
    }

    $Consultas | ForEach-Object {
        $ResultData = Invoke-SqlCommand -ConnectionString $ConnectionString -CommandText $PSItem
        $ResultDataRow = $ResultData
    }

    return $ResultDataRow
}