function Start-ConfiarloadClient {

    <#
	.SYNOPSIS
        Script para ejecutar Job Cargue cliente Confiar para automatizacion.
    .DESCRIPTION
        Generar archivo de realce (To Do)
	.EXAMPLE
        Set-RequestByStep -Driver <System.Object> -Docnumber <String> (To Do)
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (

    )

    $LoadRealceState = $null;
        
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null;
    $srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') "192.168.60.151,2430";
    $srv.ConnectionContext.LoginSecure=$false;
    $srv.ConnectionContext.set_Login("prf");
    $srv.ConnectionContext.set_Password("Tester2012*/");
    $job = $srv.jobserver.jobs["UniqueCardCajasPro - Confiar - CargaClientes"];
    $JobResponse = $job.Start();
    $startDate = Get-Date -Format "yyyy/MM/dd HH:mm";
    
    $StatusJob = 'Started';
    while ($StatusJob -ne 'Finalized') {
        Start-Sleep -Seconds 30;
        $LoadRealceState = Get-CostumerCardLoad -ConnectionString $Config.ConnectionString -Parameter $startDate;
        $LoadRealceState | ForEach-Object {
            if ($PSItem.Status -eq 'Finalized') {
                $StatusJob = 'Finalized';
            }
        }        
    }
    return $LoadRealceState;
}