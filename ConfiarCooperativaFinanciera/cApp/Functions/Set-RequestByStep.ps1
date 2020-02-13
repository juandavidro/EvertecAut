function Set-RequestByStep {

    <#
	.SYNOPSIS
        Script para avanzar las solicitudes generadas por etapa
    .DESCRIPTION
        Generar archivo de realce (To Do)
	.EXAMPLE
        Set-RequestByStep -Driver <System.Object> -Docnumber <String> (To Do)
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (
        [System.Object] $Driver,
        [string] $SequenceNumber
    )

    $return = $true;
    
    # Open "Solicitudes por etapa"
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='menuForm:tree:1_1_4:menuLink']")).click();
    Start-Sleep -Seconds 1;
    # Identification number
    $Driver.FindElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='formSelectStage:j_idt2448:identificationNumber']")).sendKeys($Sequencenumber);
    Start-Sleep -Seconds 2;
    $Driver.FindElement([OpenQA.Selenium.By]::XPath("//img[@src='/bankbu/images/next.gif']")).click();
    Start-Sleep -Seconds 2;
    # $Driver.FindElement([OpenQA.Selenium.By]::XPath("input[@id='formStage1Step2:j_idt2888:applicationsStages1Step2Table:0:check']")).click();
    #                                                           formStage1Step2:j_idt2888:advanceAllApplications
    Start-Sleep -Seconds 2;
    $Driver.FindElement([OpenQA.Selenium.By]::XPath("//input[@id='formStage1Step2:j_idt2501:advanceAllApplications']")).click();
    Start-Sleep -Seconds 5;    
    $Driver.FindElement([OpenQA.Selenium.By]::XPath("//input[@id='j_idt86:errorMessage:j_idt130']")).click();

    return $return;
}