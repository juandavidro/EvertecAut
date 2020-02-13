function Copy-FileServerToServer {

    <#
	.SYNOPSIS
        Copiar archivo de cargue de servidor a servidor
    .DESCRIPTION
        Retorna booleano como respuesta de la copia del archivo
	.EXAMPLE
        Copy-FileServerToServer -FromPath <String> -ToPath <String> -TransPath <String>
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (
        [string] $FromPath,
        [string] $ToPath,
        [string] $TransPath,
        [string] $Fromserver, # (To Do)
        [string] $ToServer # (To Do)
    )

    Write-Host 'Obteniendo el archivo generado por confiar...';
    $ConnectSftp = 'protocol=' + $Config.SftpConnectionConfiar.Protocol + ';host=' + $Config.SftpConnectionConfiar.Host + ';username=' + $Config.SftpConnectionConfiar.Username + ';password=' + $Config.SftpConnectionConfiar.Password + ';fingerprint=' + $Config.SftpConnectionConfiar.Fingerprint;
    $LoadFile = $FromPath + '/CONFIA' + (Get-Date -Format 'yyMM') + '*';
    $GetLoadFile = $ConnectSftp | Copy-FileFromServer -LocalPath $TransPath -RemotePath $LoadFile;

    $LastFile = Get-ChildItem -Path $TransPath | 
        Sort-Object LastWriteTime -Descending |
        Select-Object -first 1;
    
    Write-Host 'Copiando el archivo generado por confiar...';
    $ConnectSftp = 'protocol=' + $Config.SftpConnection.Protocol + ';host=' + $Config.SftpConnection.Host + ';username=' + $Config.SftpConnection.Username + ';password=' + $Config.SftpConnection.Password;
    $GetLoadFile = $ConnectSftp | Copy-FileToServer -LocalFile $LastFile.FullName -RemotePath $Topath;


    return $true;    
}