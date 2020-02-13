Function Get-DataMongo {
    param(
        [Parameter(Mandatory)]
        [string]$Parameter,

        [Parameter(Mandatory)]
        [string] $Value1,

        [string] $Value2
    )
    try {

        $Consulta = Select-QueryMongo -Query $Parameter -Value1 $Value1 -Value2 $Value2

        Connect-Mdbc -ConnectionString $Config.MongoConnectionString -DatabaseName $Config.MongoDatabase -Timeout 0
        $Data = Invoke-MdbcAggregate $Consulta -Collection $Database.GetCollection($Config.CollectionBifrost)
    }
    catch{
        Write-Host $_.Exception
    }


    return $Data
}