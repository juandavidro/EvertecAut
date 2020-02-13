Function Get-ContentNotification {

    <#
	.SYNOPSIS
        Retorna el contenido del mensaje que llega al correo electrónico especificado en este mismo archivo.
    .DESCRIPTION
        Crea una variable con el cuerpo del mensaje que llega al correo electrónico.
    .EXAMPLE
        Get-ContentNotification
    .NOTES
        Author:         JCastro
        Creation Date:  03/05/2019
        Purpose/Change: Desarrollo de la función inicial
    #>
<#
    param()

    try{
        
        $Email = Get-EmailContent -user $Config.ToEmailNotification -password $Config.PassEmailNotification -fromEmail $Config.FromEmailNotification
            if ($Email -eq 'Mensaje esta demorando en llegar...') {
                    Start-Sleep -s 7
                    $Email = Get-EmailContent -user $Config.ToEmailNotification -password $Config.PassEmailNotification -fromEmail $Config.FromEmailNotification
                    $Body = $Email
            }
        $Body = $Email
        
    }
    catch{
        $Body = 'Mensaje esta demorando en llegar...'
    }

    return $Body

#>
}

