Function Get-DataMongo {

    <#
	.SYNOPSIS
        Retorna un objeto con el resultado de la busqueda de una transacción de la base de datos de Mongo filtrada por el número de identifiación.
    .DESCRIPTION
        Crea un query que esta formado por el numero de identificación de la persona sobre la cual se quiere hacer la búsqueda de la transacción que haya realizado,
        despues con ese query creado hace la petición a la base de datos para retornar el resultado.
	.PARAMETER DocNumber
		Número de identificación de la persona que se quiere obtener la ultima transacción realizada.
    .EXAMPLE
        Get-DataMongo -DocNumber 1022393657
    .NOTES
        Author:         JRojass
        Purpose/Change: Desarrollo de la función inicial
    #>

    param(
        [Parameter(Mandatory)]
        [string]$DocNumber

    )
    try {
        Connect-Mdbc -ConnectionString $Config.MongoConnectionString -DatabaseName $Config.MongoDatabase -Timeout 0
        $query = New-MdbcQuery -Name 'Properties.Request.DocNumber' -EQ $DocNumber
        $ResultMongoData = Get-MdbcData -Query $query -Last 1 -Collection $Database.GetCollection($Config.CollectionKraken)
    }
    catch{
        Write-Host $_.Exception
    }


    return $ResultMongoData
}