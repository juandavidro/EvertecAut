#add references to the Selenium DLLs 
$WebDriverPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.dll"
#I unblock it because when you download a DLL from a remote source it is often blocked by default
Unblock-File $WebDriverPath
Add-Type -Path $WebDriverPath

$WebDriverSupportPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.Support.dll"
Unblock-File $WebDriverSupportPath
Add-Type -Path $WebDriverSupportPath

function Verb-Noun {
    [CmdletBinding()]
    param (
        [string] $UserName,
        [string] $Pass
    )


    # To start a Chrome Driver
    $Driver = Start-SeChrome
    Enter-SeUrl http://192.168.60.60:7007/bankbu/faces/index.xhtml -Driver $Driver
    
    $InputUser = $Driver.FindElementById("loginform:username");
    $InputUser.sendKeys("OPENCARD");

    $InputPass = $Driver.FindElementById("loginform:password");
    $InputPass.sendKeys("Opencard2*");


    $Driver.FindElementByName("loginform:j_idt21").click();

    $InputUser = $Driver.FindElementById("loginform:username");

    $InputPass = $Driver.FindElementById("loginform:password");


    
}