function Set-NewUser {

    <#
	.SYNOPSIS
        Bot para Registrar un nuevo usuario en el portal confiar
    .DESCRIPTION
        Retorna informacion del cliente Registrado (To Do)
	.EXAMPLE
        Get-Client -Driver <System.Object> -Docnumber <String[]> NewUser
    .NOTES
        Author:         jrojass
        Purpose/Change: Diseño de automatizacion cargue clientes confiar.
    #>

    param (
        [System.Object] $Driver,
        [System.Collections.Hashtable] $NewUser
    )

    $return = $false;


    # try {
		# Deploy Nucleo
		# $Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_0']//div//span//span")).click();
		# # Deploy clien information
		# $Driver.findElement([OpenQA.Selenium.By]::XPath("//li[@id='menuForm:tree_node_0']//ul//li[@id='menuForm:tree_node_0_4']//div//span//span")).click();
		# Open "ingreso clientes"

		$Driver.findElement([OpenQA.Selenium.By]::XPath("//a[@id='menuForm:tree:0_4_1:menuLink']")).click();
		Start-Sleep -Seconds 2;
		# complete the form
		$nucleo = $Driver.findElement([OpenQA.Selenium.By]::XPath("//select//option[@value='1']"));
		$nucleo.click();
		$Driver.FindElementById("consultCustomerForm:identificationNumber").sendKeys($NewUser.DocNumber);
		$Driver.FindElementById("consultCustomerForm:applicationsInputFind").click();
		Start-Sleep -Seconds 1														
		$Driver.FindElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='insertinputCustomersForm:j_idt750:names1Insert']")).sendKeys($NewUser.Name);
		$Driver.FindElementById("insertinputCustomersForm:j_idt750:lastNameInsert").sendKeys($NewUser.LastName);
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//img[@src='/bankbu/images/next.gif']")).click();
		Start-Sleep -Seconds 1														
		$Driver.FindElement([OpenQA.Selenium.By]::XPath("//tbody//tr//td//input[@id='inputCustomers2Form:j_idt1187:descriptionInput']")).sendKeys($NewUser.Address);
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//img[@onclick='inputCustomers2Form_j_idt1187_territorialEntitiesAddress_ocLovSearchCmd()']")).click();
		Start-Sleep -Seconds 1		
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//td[@class='panelGridRegisterColumnFont3']//input[@name='inputCustomers2Form:j_idt1187:territorialEntitiesAddress:j_idt340:0:j_idt344']")).sendKeys("CO0110000100000");#==>
		Start-Sleep -Seconds 1  
		$Driver.FindElementById("inputCustomers2Form:j_idt1187:territorialEntitiesAddress:j_idt353").click();
		Start-Sleep -Seconds 1
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//img[@src='/bankbu/images/flecha_1.gif']")).click();
		Start-Sleep -Seconds 1
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//img[@src='/bankbu/images/finish2.gif']")).click();	
		Start-Sleep -Seconds 1
		$Driver.findElement([OpenQA.Selenium.By]::XPath("//img[@src='/bankbu/images/finish2.gif']")).click();

		# return info 



    # }
    # catch {
    #     $return = $true;
    # }

    return $return;
}