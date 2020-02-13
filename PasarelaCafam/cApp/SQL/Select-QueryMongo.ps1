function Select-QueryMongo {
    param(

        [Parameter(Mandatory)]
        [String]
        $Query,

        [Parameter(Mandatory)]
        [String]
        $Value1,

        [String]
        $Value2
    )

    switch ( $Query ) {
        'QueryReversoTipos' {
            @(
                @{'$match' =
                    @{  'Properties.Request.acquirerCode'  = $Value1
                        'Properties.Request.DocType'       = $Value2
                        'Properties.Response.ResponseCode' = '200'
                    }
                }
                @{'$sort' = @{Timestamp = -1 } }
                @{'$limit' = 1 }
            )
        }
        'Compra' { Invoke-Pester .\Compra.Tests.ps1 }
        'Reverso de Compra' { Invoke-Pester .\ReversoCompra.Tests.ps1 }
        'Anulaci�de Compra' { $result = 'Wednesday' }
        'Reverso Anulaci�de Compra' {
            $result = 'Thursday'
        }
    }
}