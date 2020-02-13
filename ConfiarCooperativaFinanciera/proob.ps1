#add references to the Selenium DLLs 
$WebDriverPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.dll"
#I unblock it because when you download a DLL from a remote source it is often blocked by default
Unblock-File $WebDriverPath
Add-Type -Path $WebDriverPath

$WebDriverSupportPath = Resolve-Path "C:\Program Files\WindowsPowerShell\Modules\Selenium\1.2\assemblies\WebDriver.Support.dll"
Unblock-File $WebDriverSupportPath
Add-Type -Path $WebDriverSupportPath

# To start a Chrome Driver
$Driver = Start-SeChrome
Enter-SeUrl http://192.168.60.60:7007/bankbu/faces/index.xhtml -Driver $Driver

$input = $Driver.FindElementById("loginform:username");
$input.sendKeys("OPENCARD");
$Driver.FindElementById("loginform:password").sendKeys("Opencard2*");
$Driver.FindElementByName("loginform:j_idt21").click();

        # WebElement userName = driver.findElement(By.id("loginform:username"));
        # userName.sendKeys(user);
        
        # // Set the user pass
        # WebElement passUser = driver.findElement(By.id("loginform:password"));
        # passUser.sendKeys(pass);
        # Thread.sleep(3000);
        
        # // Log-in portal
        # driver.findElement(By.name("loginform:j_idt21")).click();

# #now we create a default service so we can run Selenium without the black debug command prompt appearing
# #pre-PowerShell 5 we can do it like so

# #PowerShell 5 we can do it like so
# #$defaultservice = [OpenQA.Selenium.IE.InternetExplorerDriverService]::CreateDefaultService()

# #hide command prompt
# $defaultservice.HideCommandPromptWindow = $true;

# #provide our default service and selenium options to the Internett Explorer driver (calling this opens the IE session)
# $seleniumDriver = New-Object OpenQA.Selenium.IE.InternetExplorerDriver -ArgumentList @($defaultservice, $seleniumOptions)

# #now we start clicking elements on the web page.  We do this by finding the ID of the element we want to interact with.

# #enter a username into login prompt
# $seleniumWait = New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($seleniumDriver, (New-TimeSpan -Seconds 10))
# $seleniumWait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::Id("textfield-1011-inputEl")))
# $seleniumDriver.FindElementById("username_text").SendKeys("exampleusernname")

# #enter a password into login prompt
# $seleniumWait = New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($seleniumDriver, (New-TimeSpan -Seconds 10))
# $seleniumWait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::Id("textfield-1012-inputEl")))
# $seleniumDriver.FindElementById("password_text").SendKeys("examplepassword")

# #click 'login' button
# $seleniumWait = New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($seleniumDriver, (New-TimeSpan -Seconds 10))
# $seleniumWait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::Id("loginButton")))
# $seleniumDriver.FindElementById("loginButton").Click()

# #when logged in, click another button
# $seleniumWait = New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($seleniumDriver, (New-TimeSpan -Seconds 10))
# $seleniumWait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::Id("button-1025")))
# $seleniumDriver.FindElementById("random_button").Click()

# #we don't close it in this instance because we want to keep the browser open as a dashboard view
# #$seleniumDriver.Close()
# #$seleniumDriver.Dispose()
# #$seleniumDriver.Quit()