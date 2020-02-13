function Set-PlasticsAdmin {

    <#
	.SYNOPSIS
        Bot para generar el realce de plasticos al portal TUP
    .DESCRIPTION
        Generar archivo de realce (To Do)
	.EXAMPLE
        Set-PlasticsAdmin -Driver <System.Object> -Docnumber <String> (To Do)
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (
        [System.Object]$Driver,
        [String] $SequenceNumber
    )

    # Open "Plasticos a realzar" 
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='menuForm:tree:1_7_0_0:menuLink']")).click();
    Start-Sleep -Seconds 2                                        
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//input[@id='cardsToEmbossForm:j_idt299:application']")).sendKeys($SequenceNumber);
    Start-Sleep -Seconds 1
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='cardsToEmbossForm:j_idt299:ocWzdNext']//img[@src='/bankbu/images/next.gif']")).click();
    Start-Sleep -Seconds 8
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//input[@id='cardsToEmboss2Form:j_idt2595:generateAll']")).click();
    Start-Sleep -Seconds 15;
    #Verificar mensaje de repuesta span id='j_idt86:errorMessage:j_idt115:overlayPanelGroup'
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//input[@id='j_idt86:errorMessage:j_idt130']")).click();

}