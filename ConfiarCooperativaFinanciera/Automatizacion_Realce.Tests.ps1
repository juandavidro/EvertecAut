$PathEvidencias = Join-Path $PSScriptRoot -ChildPath '\Evidencias\ConsultaMovimientos' #Ruta donde se almacenan las evidencias
$PathLoadClientI = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadI\*' #Ruta donde se almacenan las archivos de cargue novedad I
$PathLoadClientM = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadM\*' #Ruta donde se almacenan las archivos de cargue novedad M
$PathLoadClientP = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadP\*' #Ruta donde se almacenan las archivos de cargue novedad P
$PathLoadClientR = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadR\*' #Ruta donde se almacenan las archivos de cargue novedad R
$PathLoadClientT = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadT\*' #Ruta donde se almacenan las archivos de cargue novedad T
$PathLoadClientU = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadU\*' #Ruta donde se almacenan las archivos de cargue novedad U
$PathLoadClientW = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadW\*' #Ruta donde se almacenan las archivos de cargue novedad W

# $NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadI" -TypeCase "Exito" -NumberCase "1"
$NameCaseSuccess1 = "CFR-902 :: Versión : 1 :: Cargue clientes novedad I";
Describe "Exito - $($NameCaseSuccess1)" {
       
    try {
        Write-Host 'Copiando el archivo existente de cargue de clientes al sftp...';
        $ConnectSftp = 'protocol=' + $Config.SftpConnection.Protocol + ';host=' + $Config.SftpConnection.Host + ';username=' + $Config.SftpConnection.Username + ';password=' + $Config.SftpConnection.Password;

        $LoadClients = (Get-Item $PathLoadClientI -Filter *.txt).FullName;

        # $UserData = Get-UserFileData

        if ($LoadClients -ne $null) {
            
            $SftpResponse = $null;
            
            $FileUserData = Get-DocNumber -Type "LoadClient" -TextFile $LoadClients;            

            # $TupUserData = Get-CostumerUpLoad -ConnectionString $Config.ConnectionString -Parameter $FileUserData.DocNumber;
            
            $SftpResponse = $ConnectSftp | Copy-FileToServer -LocalFile $LoadClients -RemotePath $Config.FtpRemoteDirectoryIn;   
            
            $LoadCardResponse = Start-ConfiarloadClient;           
            
            It "El archivo de cargue cliente debe existir en la ruta especifica para la novedad I" {
                $LoadClients | Should -Not -BeNullOrEmpty;
            }
            It "La respuesta del sftp debe ser diferente de NULL" {
                $SftpResponse | Should -Not -BeNullOrEmpty;
            }
            $LoadCardResponse | ForEach-Object {
                It $PSItem.Description {
                    $PSItem.Status | Should -BeIn @("Started","Success","Finalized");
                }
            }

            $FileUserData | ForEach-Object {
                if ($PSItem.DocNumber -ne $null) {
                    
                    $TupUserData = Get-CostumerUpLoad -ConnectionString $Config.ConnectionString -Parameter $PSItem.DocNumber;
                    
                    It "Se verifica el nmero de identificacion del usuario en TUP" {
                        $TupUserData.PersonIdentification | Should -Be $PSItem.DocNumber;
                    }
                    It "Se verifica el nmero de PAN del usuario en TUP" {
                        $TupUserData.PersonIdentification | Should -Be $PSItem.DocNumber;
                    }
                    It "Se verifica el nombre del usuario en TUP" {
                        $TupUserData.PersonIdentification | Should -Be $PSItem.DocNumber;
                    }
                    It "Se verifica el apellido del usuario en TUP" {
                        $TupUserData.PersonIdentification | Should -Be $PSItem.DocNumber;
                    }
                }
            }
        }else {
            It 'No existe el archivo de cargue en la ruta especifica para la novedad I.' -Skip { }    
        }
    }
    catch {
        $Response = $_.Exception
        It 'Fallo en el paso del archivo al sftp o ejecucion del job.' -Skip { }
    }
        
}

# $NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadM" -TypeCase "Exito" -NumberCase "1"
$NameCaseSuccess2 = "CFR-938 :: Versión : 1 :: Cargue clientes novedad P";
Describe "Exito - $($NameCaseSuccess2)" {
       
    try {
        Write-Host 'Copiando el archivo existente de cargue de clientes al sftp...';
        $ConnectSftp = 'protocol=' + $Config.SftpConnection.Protocol + ';host=' + $Config.SftpConnection.Host + ';username=' + $Config.SftpConnection.Username + ';password=' + $Config.SftpConnection.Password + ';fingerprint=' + $Config.SftpConnection.Fingerprint;

        $LoadClients = (Get-Item $PathLoadClientP -Filter *.txt).FullName;

        if ($LoadClients -ne $null) {
            
            $SftpResponse = $null;
            
            if ($LoadClients -ne $null) {
                $SftpResponse = $ConnectSftp | Copy-FileToServer -LocalFile $LoadClients -RemotePath $Config.FtpRemoteDirectoryIn    
            }
            
            $LoadCardResponse = Start-ConfiarloadClient;
            
            $DocNumbers = Get-DocNumber -Type "LoadClient" -TextFile $LoadClients;
            
            
            It "El archivo de cargue cliente debe existir en la ruta especifica para la novedad P" {
                $LoadClients | Should -Not -BeNullOrEmpty;
            }
            It "La respuesta del sftp debe ser diferente de NULL" {
                $SftpResponse | Should -Not -BeNullOrEmpty;
            }
            $LoadCardResponse | ForEach-Object {
                It $PSItem.Description {
                    $PSItem.Status | Should -BeIn @("Started","Success","Finalized");
                }
            }     
            
        }else {
            It 'No existe el archivo de cargue en la ruta especifica para la novedad P.' -Skip { }    
        }
    }
    catch {
        $Response = $_.Exception;
        It 'Fallo en el paso del archivo al sftp o ejecucion del job.' -Skip { }
    }
        
}

# $NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadM" -TypeCase "Exito" -NumberCase "1"
$NameCaseSuccess2 = "CFR-965 :: Versión : 1 :: Cargue clientes novedad U.";
Describe "Exito - $($NameCaseSuccess2)" {
       
    try {
        Write-Host 'Copiando el archivo existente de cargue de clientes al sftp...';
        $ConnectSftp = 'protocol=' + $Config.SftpConnection.Protocol + ';host=' + $Config.SftpConnection.Host + ';username=' + $Config.SftpConnection.Username + ';password=' + $Config.SftpConnection.Password + ';fingerprint=' + $Config.SftpConnection.Fingerprint;

        $LoadClients = (Get-Item $PathLoadClientU -Filter *.txt).FullName;

        if ($LoadClients -ne $null) {
            
            $SftpResponse = $null;
            
            if ($LoadClients -ne $null) {
                $SftpResponse = $ConnectSftp | Copy-FileToServer -LocalFile $LoadClients -RemotePath $Config.FtpRemoteDirectoryIn;
            }
            
            $LoadCardResponse = Start-ConfiarloadClient;
            
            $DocNumbers = Get-DocNumber -Type "LoadClient" -TextFile $LoadClients;
            
            
            It "El archivo de cargue cliente debe existir en la ruta especifica para la novedad U" {
                $LoadClients | Should -Not -BeNullOrEmpty;
            }
            It "La respuesta del sftp debe ser diferente de NULL" {
                $SftpResponse | Should -Not -BeNullOrEmpty;
            }
            $LoadCardResponse | ForEach-Object {
                It $PSItem.Description {
                    $PSItem.Status | Should -BeIn @("Started","Success","Finalized");
                }
            }     
            
        }else {
            It 'No existe el archivo de cargue en la ruta especifica para la novedad U.' -Skip { }    
        }
    }
    catch {
        $Response = $_.Exception;
        It 'Fallo en el paso del archivo al sftp o ejecucion del job.' -Skip { }
    }
        
}

# $NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadM" -TypeCase "Exito" -NumberCase "1"
$NameCaseSuccess2 = "CFR-999 :: Versión : 1 :: Novedad R generar nueva tarjeta.";
Describe "Exito - $($NameCaseSuccess2)" {
       
    try {
        Write-Host 'Copiando el archivo existente de cargue de clientes al sftp...';
        $ConnectSftp = 'protocol=' + $Config.SftpConnection.Protocol + ';host=' + $Config.SftpConnection.Host + ';username=' + $Config.SftpConnection.Username + ';password=' + $Config.SftpConnection.Password + ';fingerprint=' + $Config.SftpConnection.Fingerprint;

        $LoadClients = (Get-Item $PathLoadClientR -Filter *.txt).FullName;

        if ($LoadClients -ne $null) {
            
            $SftpResponse = $null;
            
            if ($LoadClients -ne $null) {
                $SftpResponse = $ConnectSftp | Copy-FileToServer -LocalFile $LoadClients -RemotePath $Config.FtpRemoteDirectoryIn;
            }
            
            $LoadCardResponse = Start-ConfiarloadClient;
            
            $DocNumbers = Get-DocNumber -Type "LoadClient" -TextFile $LoadClients;
            
            
            It "El archivo de cargue cliente debe existir en la ruta especifica para la novedad R" {
                $LoadClients | Should -Not -BeNullOrEmpty;
            }
            It "La respuesta del sftp debe ser diferente de NULL" {
                $SftpResponse | Should -Not -BeNullOrEmpty;
            }
            $LoadCardResponse | ForEach-Object {
                It $PSItem.Description {
                    $PSItem.Status | Should -BeIn @("Started","Success","Finalized");
                }
            }     
            
        }else {
            It 'No existe el archivo de cargue en la ruta especifica para la novedad R.' -Skip { }    
        }
    }
    catch {
        $Response = $_.Exception;
        It 'Fallo en el paso del archivo al sftp o ejecucion del job.' -Skip { }
    }
        
}


# $NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadM" -TypeCase "Exito" -NumberCase "1"
$NameCaseSuccess2 = "CFR-1112 :: Versión : 1 :: Cargue cliente Novedad M.";
Describe "Exito - $($NameCaseSuccess2)" {
       
    try {
        Write-Host 'Copiando el archivo existente de cargue de clientes al sftp...';
        $ConnectSftp = 'protocol=' + $Config.SftpConnection.Protocol + ';host=' + $Config.SftpConnection.Host + ';username=' + $Config.SftpConnection.Username + ';password=' + $Config.SftpConnection.Password + ';fingerprint=' + $Config.SftpConnection.Fingerprint;

        $LoadClients = (Get-Item $PathLoadClientM -Filter *.txt).FullName;

        if ($LoadClients -ne $null) {
            
            $SftpResponse = $null;
            
            if ($LoadClients -ne $null) {
                $SftpResponse = $ConnectSftp | Copy-FileToServer -LocalFile $LoadClients -RemotePath $Config.FtpRemoteDirectoryIn;
            }
            
            $LoadCardResponse = Start-ConfiarloadClient;
            
            $DocNumbers = Get-DocNumber -Type "LoadClient" -TextFile $LoadClients;
            
            
            It "El archivo de cargue cliente debe existir en la ruta especifica para la novedad M" {
                $LoadClients | Should -Not -BeNullOrEmpty;
            }
            It "La respuesta del sftp debe ser diferente de NULL" {
                $SftpResponse | Should -Not -BeNullOrEmpty;
            }
            $LoadCardResponse | ForEach-Object {
                It $PSItem.Description {
                    $PSItem.Status | Should -BeIn @("Started","Success","Finalized");
                }
            }     
            
        }else {
            It 'No existe el archivo de cargue en la ruta especifica para la novedad M.' -Skip { }    
        }
    }
    catch {
        $Response = $_.Exception;
        It 'Fallo en el paso del archivo al sftp o ejecucion del job.' -Skip { }
    }
        
}