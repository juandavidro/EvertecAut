function Set-Login {

    <#
	.SYNOPSIS
        Bot para acceder al portal BankBu.
    .DESCRIPTION
        Retorna booleno si accede al portal.
	.EXAMPLE
        Set-Login -Driver <System.Object> -User <String> -Password <String> (To Do)
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (
        [System.Object] $Driver,
        [string] $Username,
        [string] $Password
    )
    $return = $false;

    Enter-SeUrl http://192.168.60.60:7007/bankbu/faces/index.xhtml -Driver $Driver

    $InputUser = $Driver.FindElementById("loginform:username");
    $InputUser.sendKeys($username);
    $InputPass = $Driver.FindElementById("loginform:password");
    $InputPass.sendKeys($password);

    $Driver.FindElementByName("loginform:j_idt21").click();


    try {
        $InputUser = $Driver.FindElementById("loginform:username");

        $InputPass = $Driver.FindElementById("loginform:password");    
    }
    catch {
        $return = $true;
    }

    return $return;
}