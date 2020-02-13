function Get-DocNumber {
    <#
	.SYNOPSIS
        Script para obtener los numeros de documento o tarjeta de los archivos de cargue
    .DESCRIPTION
        Retorna los numeros de documento o tarjeta de los cliente en el archivo de cargue
	.EXAMPLE
        Get-DocNumber -Type <String> -TextFile <String>
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>
    param (
        [string] $Type,
        [string] $TextFile
    )

    $DataUsers = @();

    foreach($line in Get-Content $TextFile) {
        try{
            $line;
            if ($Type -eq "LoadClient") { 
                if ($line.Substring(28,20) -match "      "){
                }else{
                    $DataUsers += @{
                        'DocType' = [int] $line.Substring(26,2);
                        'Novelty' = $line.Substring(0,1);
                        'DocNumber' = [int] $line.Substring(28,20);
                        'Name' = $line.Substring(48,50);
                        'LastName' = $line.Substring(98,50);
                    }
                }
            }
            elseif ($Type -eq "LoadBlock") {              
                if ($line.Substring(2,6) -match "      "){
                }else{
                    $DataUsers += @{
                        'CardNumber' = $line.Substring(2,16);
                    }
                }
            }
        } catch{
            Write-Host "continue";
        }
    }

    return $DataUsers;
    
}