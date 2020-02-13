function Lock-Client {

    <#
	.SYNOPSIS
        Bot para bloquear cliente en portal BankBu.
    .DESCRIPTION
        Retorna el estado del bloqueo
	.EXAMPLE
        Set-Login -Driver <System.Object> -User <String> -Password <String> (To Do)
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (
        [System.Object] $Driver,
        [string] $CardNumber
    )
    $return = $true;

    try {   
        $Driver.FindElementById("groupExecitionForm:crudPager:pageNext").click();
        Start-Sleep -Seconds 2;
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//input[@value='53|1|']")).click();
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='groupExecitionForm:update']")).click();
        Start-Sleep -Seconds 2;
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//input[@id='processExecitionForm:crudDataTable:3:check']")).click();
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//input[@id='processExecitionForm:submitInsert']")).click();
        Start-Sleep -Seconds 3;    
        $Driver.findElement([OpenQA.Selenium.By]::XPath("//button[@id='formDialogs:confirmProcessExecution']//span")).click();
        Write-Host "Ejecutando proceso de Bloqueos Masivos...",
        Start-Sleep -Seconds 15;        
    }  catch {
        $return = $false;
    }

    return $return;
}