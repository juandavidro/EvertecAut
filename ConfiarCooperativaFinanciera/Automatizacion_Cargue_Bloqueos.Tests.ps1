$ChildPath = '\Evidencias\' + $Client + '\Compra'
$PathEvidencias = Join-Path $PSScriptRoot -ChildPath $ChildPath #Ruta donde se almacenan las evidencias
Add-Type -Path "C:\Program Files\WindowsPowerShell\Modules\WinSCP\5.15.9.0\lib\WinSCPnet.dll"

if (Test-Path -Path $PathEvidencias ) {
}
else {
    New-Item -Path $PathEvidencias -ItemType Directory
}

# $NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadI" -TypeCase "Exito" -NumberCase "1"
$NameCaseSuccess1 = "Bloqueo definitivo cliente en BanckBu y TUP"
Describe "Éxito - $($NameCaseSuccess1): $($_.IdentificationType)-$($_.PersonIdentification)" {
  
    #Copy file to server
    # Load WinSCP .NET assembly

# Set up session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $Config.SftpConnectionConfiar.Host
        UserName = $Config.SftpConnectionConfiar.Username
        Password = $Config.SftpConnectionConfiar.Password
        SshHostKeyFingerprint = $Config.SftpConnectionConfiar.Fingerprint
    }
    $session = New-Object WinSCP.Session;
    $session.Open($sessionOptions);

    try {
        $session.RemoveFiles("/inout/confiar3/In/BLOQUEOS_MASIVOS.txt");        
        $session.PutFiles("C:\Users\jrojass\Documents\automatizaciones\ConfiarCooperativaFinanciera\Evidencias\LoadLock\BLOQUEOS_MASIVOS.txt", "/inout/confiar3/In/").Check();
    }
    catch {
        Write-Host "El archivo no existe";
    }




    # To start a Chrome Driver
    $Driver = Start-SeChrome -Arguments @("start-maximized");
    $LogedIn = Set-Login -Driver $Driver -username $Config.BankBuAdmin.username -password $Config.BankBuAdmin.password;
    
    $CreditCard = Get-DocNumber -Type "LoadBlock" -TextFile $Config.LockFile;
    
    if ($LogedIn) {
        $CardNumber = $CreditCard.CardNumber;

        # # Deploy Nucleo
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_0']//div//span//span")).click();
		# # Deploy clien information
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_0']//ul//li[@id='menuForm:tree_node_0_3']//div//span//span")).click();
        # # select independent groups 
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='menuForm:tree:0_3_3:menuLink']")).click();
        Start-Sleep -Seconds 2;
        $LockState = Lock-Client -Driver $Driver -CardNumber $CardNumber;

        # if ($LockState) {
        #     # # Deploy emisor
        #     $Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_1']//div//span//span")).click();
        #     $Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_1']//ul//li[@id='menuForm:tree_node_1_3']//div//span//span")).click();
        # }


        # # TUP Lock client
        $CreditCard = Get-DocNumber -Type "LoadBlock" -TextFile $Config.LockFile;

        Lock-TupClient -ConnectionString $Config.ConnectionString -CardNumber $CreditCard.CardNumber;
    
        $LockResponse = Watch-TupCardLock -ConnectionString $Config.ConnectionString -CardNumber $CreditCard.CardNumber;

        It "La consulta del cliente debe ser diferente de null" {
            $LockResponse | Should -Not -Be $null
        }
        It "El numero de tarjeta debe ser el mismo de la solicitud" {
            $LockResponse.Pan | Should -Be $CardNumber
        }
        It "El estado del cliente debe estar activo" {
            $LockResponse.State | Should -Be "True"
        }
        It "El cliente quedo con bloqueo de plastico definitivo BB" {
            $LockResponse.HoldResponse | Should -Be "BB"
        }


    }
    

}
