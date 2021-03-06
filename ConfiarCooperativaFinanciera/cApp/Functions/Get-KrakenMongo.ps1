Function Get-KrakenMongo {

    <#
	.SYNOPSIS
        Retorna un objeto con el resultado de la busqueda de una transacción de la base de datos de Mongo filtrada por el número de identifiación.
    .DESCRIPTION
        Crea un query que esta formado por el numero de identificación de la persona sobre la cual se quiere hacer la búsqueda de la transacción que haya realizado,
        despues con ese query creado hace la petición a la base de datos para retornar el resultado.
	.PARAMETER DocNumber
        Número de identificación de la persona que se quiere obtener la ultima transacción realizada.
    .PARAMETER DocType
		Tipo de identficación de la persona que se quiere obtener la ultima transacción realizada.
    .EXAMPLE
        Get-KrakenMongo -DocNumber 1022393657 -DocType 'TI'
    .NOTES
        Author:         JCastro
        Creation Date:  03/05/2019
        Purpose/Change: Desarrollo de la función inicial
    #>

    param(
        [Parameter(Mandatory)]
        [string]$DocType,
        [string]$DocNumber,
        [string]$CorrelationalId
    )
    try {
        Connect-Mdbc -ConnectionString $Config.MongoConnectionString -DatabaseName $Config.MongoDatabase -Timeout 0

        $NotificationKraken = Invoke-MdbcAggregate -Pipeline  @(
            @{'$match' =
                @{  'Properties.Request.DocNumber' = $DocNumber
                    'Properties.Request.DocType'   = $DocType
                    'Properties.Request.CorrelationalId'   = $CorrelationalId
                }
            }
            @{'$sort' = @{Timestamp = -1 } }
            @{'$limit' = 1 }
        ) -Collection $Database.GetCollection($Config.CollectionKraken)
    }
    catch {
        Write-Host $_.Exception
    }
    return $NotificationKraken
}