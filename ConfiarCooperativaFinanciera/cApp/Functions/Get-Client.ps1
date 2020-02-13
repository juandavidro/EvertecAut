
function Get-Client {

    <#
	.SYNOPSIS
        Bot para obtener un cliente registrado
    .DESCRIPTION
        Retorna informacion del cliente solicitado (To Do)
	.EXAMPLE
        Get-Client -Driver <System.Object> -Docnumber <String>
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (
        [System.Object] $Driver,
        [string] $DocNumber
    )

    # Menu "Informacion cliente" deployed

    $return = $null;

    # Open "ingreso clientes"
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='menuForm:tree:0_4_4:menuLink']")).click();
    Start-Sleep -Seconds 4
    # Complete form to find client
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//tr//td//select//option[@value='1']")).click();
    $Driver.FindElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='customerSearchForm:identificationNumber']")).sendKeys($DocNumber);
    Start-Sleep -Seconds 4
    $Driver.findElementById("customerSearchForm:find").click();
    Start-Sleep -Seconds 4

    try {
        $return = $Driver.FindElement([OpenQA.Selenium.By]::XPath("//a[@id='customerSearchForm:crudDataTable:0:identification']")).getAttribute("innerHTML");        
    }
    catch {
        $return = $null;
    }
    return $return;
    
}