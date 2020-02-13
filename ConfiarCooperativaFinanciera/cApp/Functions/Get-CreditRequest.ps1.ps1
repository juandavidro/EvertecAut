function Get-Creditrequest{

     <#
	.SYNOPSIS
        Bot para solicitar credito de un cliente registrado
    .DESCRIPTION
        Retorna informacion del cliente y credito solicitado (To Do)
	.EXAMPLE
        Get-Client -Driver <System.Object> -Docnumber <String> (To Do)
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (
        [System.Object] $Driver,
        [System.Collections.Hashtable] $NewUser
    )

    $return = $false; 


    # Open "ingreso solicitudes - Creditos nuevos" 
    # Find new client
    Start-Sleep -Seconds 2
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='menuForm:tree:1_1_2:menuLink']")).click();
    Start-Sleep -Seconds 2
    $Driver.FindElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='consultCustomerForm:identificationNumber']")).sendKeys($NewUser.DocNumber);
    ##
    Start-Sleep -Seconds 1
    $Driver.FindElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='consultCustomerForm:find']")).click();
    ##
    Start-Sleep -Seconds 1

    ## Make verification name
    
    # click on "Adicionar"
    $Driver.FindElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//a[@id='consultCustomerForm:insert']")).click();
    Start-Sleep -Seconds 1

    # Complete "Ingreso de solicitudes" form
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//select//option[@value='2']")).click();
    # Select product
    Start-Sleep -Seconds 1
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//img[@onclick='insertapplicationsInputForm_products_ocLovSearchCmd()']")).click();
    ##
    Start-Sleep -Seconds 1
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='insertapplicationsInputForm:products:j_idt373:0:j_idt376']//img[@src='/bankbu/images/flecha_1.gif']")).click();
    ##
    Start-Sleep -Seconds 1
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//span//input[@id='insertapplicationsInputForm:submitInsert']")).click();
    Start-Sleep -Seconds 1

    $Driver.findElement([OpenQA.Selenium.By]::XPath("//button[@id='formDialogs:declineSelectApplications']//span[@class='ui-button-text']")).click();
    Start-Sleep -Seconds 7

    # Choose radication sucursal                                                      
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//div//input[@id='inputHolderOnlyForm:j_idt1767:branches:j_idt428:0:ctlKey']")).sendKeys('0');#=>
    ##
    Start-Sleep -Seconds 1
    #=>
    # Start-Sleep -Seconds 1
    # $Driver.findElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='inputHolderOnlyForm:j_idt2312:approvalCrLimit']")).sendKeys('500000');
    #=>

    # Nest step
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//a//img[@src='/bankbu/images/next.gif']")).click();
    Start-Sleep -Seconds 3

    $Driver.findElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='inputHolderOnlyForm:j_idt2165:crudDataTable:0:approvalCrLimitValue']")).sendKeys($NewUser.CreditValue);
    ##
    Start-Sleep -Seconds 1    
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='inputHolderOnlyForm:j_idt2165:crudDataTable:1:approvalCrLimitValue']")).sendKeys($NewUser.CreditValue);
    Start-Sleep -Seconds 3
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//a//img[@src='/bankbu/images/next.gif']")).click();
    ##
    Start-Sleep -Seconds 2
    $Driver.findElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//a//img[@src='/bankbu/images/finish2.gif']")).click();
    Start-Sleep -Seconds 2
    # Final step: Get user info.

    try {        
        $SequenceNum = $Driver.FindElement([OpenQA.Selenium.By]::XPath("//table[@id='consultCustomerForm:crudDataTable']//tbody//tr//td//span[@class='dataTableColumnStyle']")).getAttribute("innerHTML");
        return $SequenceNum;
    }
    catch {
        return $false
    }    
} 