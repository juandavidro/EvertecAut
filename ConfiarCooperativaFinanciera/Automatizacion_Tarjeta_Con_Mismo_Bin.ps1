$PathEvidencias = Join-Path $PSScriptRoot -ChildPath '\Evidencias\ConsultaMovimientos' #Ruta donde se almacenan las evidencias
$PathLoadLocks = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadI\*' #Ruta donde se almacenan las evidencias
if (Test-Path -Path $PathEvidencias ) {
}
else {
    New-Item -Path $PathEvidencias -ItemType Directory
}

#add references to the Selenium DLLs 
$WebDriverPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.dll"
#I unblock it because when you download a DLL from a remote source it is often blocked by default
Unblock-File $WebDriverPath
Add-Type -Path $WebDriverPath

$WebDriverSupportPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.Support.dll"
Unblock-File $WebDriverSupportPath
Add-Type -Path $WebDriverSupportPath


$PathEvidencias = Join-Path $PSScriptRoot -ChildPath '\Evidencias\ConsultaMovimientos' #Ruta donde se almacenan las evidencias
$PathLoadLocks = Join-Path $PSScriptRoot -ChildPath '\Evidencias\LoadClient\NovedadI\*' #Ruta donde se almacenan las evidencias
$LocalPath = Join-Path $PSScriptRoot -ChildPath '\Evidencias\Compra'
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
if (Test-Path -Path $PathEvidencias ) {
}
else {
    New-Item -Path $PathEvidencias -ItemType Directory
}

# Start-ConfiarLoadClient;

$NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadI" -TypeCase "Exito" -NumberCase "1"
Describe "Éxito - $($NameCaseSuccess1): $($_.IdentificationType)-$($_.PersonIdentification)" {
       
    
    # To start a Chrome Driver
    $Driver = Start-SeChrome -Arguments @("start-maximized");
    
    $LogedIn = Set-Login -Driver $Driver -username $Config.BankBuAdmin.username -password $Config.BankBuAdmin.password;

    Write-Host 'FTPsucces';

    if ($LogedIn) {

        # # Deploy Nucleo
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_0']//div//span//span")).click();
		# # Deploy clien information
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_0']//ul//li[@id='menuForm:tree_node_0_4']//div//span//span")).click();
        
        # # Verificar cliente        
        # Get client saved

        $DocUser = Get-client -Driver $Driver -DocNumber $Config.NewUser.Docnumber;
        # Make credit request

        $TupUserData = Watch-TupCardLock -ConnectionString $Config.ConnectionString -CardNumber $Config.OldUser.Docnumber;

        It "La consulta del cliente debe ser diferente de null" {
            $TupUserData | Should -Not -Be $null
        }
        It "El estado del cliente debe estar activo" {
            $TupUserData.State | Should -Be "True"
        }
        It "El cliente debe estar con bloqueo de plastico definitivo BB" {
            $TupUserData.HoldResponse | Should -Be "BB"
        }

        # Deploy Emisor
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_1']//div//span//span")).click();
		# Deploy client request
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_1']//ul//li[@id='menuForm:tree_node_1_1']//div//span//span")).click();
        # Make Credit Request
        $SequenceNum = Get-Creditrequest -Driver $Driver -NewUser $Config.NewUser;
        # $SequenceNum = '239532';
        # Move Request By Steps
        Set-RequestByStep -Driver $Driver -SequenceNumber $Config.OldUser.DocNumber;
        
        # Deploy plastic admin
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//ul//li[@id='menuForm:tree_node_1_7']//div//span//span")).click();
        # Deploy Realce
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_1_7_0']//div//span//span")).click();
        
        # Admin plastics
        Set-PlasticsAdmin -Driver $Driver -SequenceNumber $SequenceNum;
        # Move file from sftp server to sftp server
        Copy-FileServerToServer -FromPath '/inout/confiar3/Out' -ToPath $Config.FtpRemoteDirectoryIn -TransPath $LocalPath;
        # Execute 
        Start-ConfiarLoadClient;

        Write-Host "Fin";
    }

    
}

# Start-ConfiarLoadClient;

$NameCaseSuccess1 = Get-NameCase -TransactionName "CargueClientes" -Novelty "NovedadI" -TypeCase "Exito" -NumberCase "1"
Describe "Éxito - $($NameCaseSuccess1): $($_.IdentificationType)-$($_.PersonIdentification)" {
       
    
    # To start a Chrome Driver
    $Driver = Start-SeChrome -Arguments @("start-maximized");
    
    $LogedIn = Set-Login -Driver $Driver -username $Config.BankBuAdmin.username -password $Config.BankBuAdmin.password;

    Write-Host 'FTPsucces';

    if ($LogedIn) {

        # # Deploy Nucleo
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_0']//div//span//span")).click();
		# # Deploy clien information
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_0']//ul//li[@id='menuForm:tree_node_0_4']//div//span//span")).click();
        
        # # Verificar cliente        
        # Get client saved

        $DocUser = Get-client -Driver $Driver -DocNumber $Config.NewUser.Docnumber;
        # Make credit request

        $TupUserData = Watch-TupCardLock -ConnectionString $Config.ConnectionString -CardNumber $Config.OldUser.Docnumber;

        It "La consulta del cliente debe ser diferente de null" {
            $TupUserData | Should -Not -Be $null
        }
        It "El estado del cliente debe estar activo" {
            $TupUserData.State | Should -Be "True"
        }
        It "El cliente debe estar con bloqueo de plastico definitivo BB" {
            $TupUserData.HoldResponse | Should -Not -Be "BB"
        }

        # Deploy Emisor
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_1']//div//span//span")).click();
		# Deploy client request
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_1']//ul//li[@id='menuForm:tree_node_1_1']//div//span//span")).click();
        # Make Credit Request
        $SequenceNum = Get-Creditrequest -Driver $Driver -NewUser $Config.NewUser;
        # $SequenceNum = '239532';
        # Move Request By Steps
        Set-RequestByStep -Driver $Driver -SequenceNumber $Config.OldUser.DocNumber;
        
        # Deploy plastic admin
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//ul//li[@id='menuForm:tree_node_1_7']//div//span//span")).click();
        # Deploy Realce
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_1_7_0']//div//span//span")).click();
        
        # Admin plastics
        Set-PlasticsAdmin -Driver $Driver -SequenceNumber $SequenceNum;
        # Move file from sftp server to sftp server
        Copy-FileServerToServer -FromPath '/inout/confiar3/Out' -ToPath $Config.FtpRemoteDirectoryIn -TransPath $LocalPath;
        # Execute 
        Start-ConfiarLoadClient;

        Write-Host "Fin";
    }

    
}