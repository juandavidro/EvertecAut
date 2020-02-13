Function Get-EmailContent {

    <#
	.SYNOPSIS
        Retorna el contenido del mensaje que llega al correo electrónico especificado en este mismo archivo.
    .DESCRIPTION
        Crea una variable con el cuerpo del mensaje que llega al correo electrónico.
    .PARAMETER user
        Usuario de la cuenta de correo electrónico de la cual se quiere obtener el contenido del respectivo mensaje.
    .PARAMETER password
        Contraseña de la cuenta para acceder al correo electrónico y poder sacar la información.
    .PARAMETER fromEmail
		Correo del remitente para realizar el filtro del mensaje sobre el cual se quiere obtener el contenido.
    .EXAMPLE
        Get-EmailContent -user pruebastoken@gmail.com -password Aq123456 -fromEmail enviotokens@evertecinc.com
    .NOTES
        Author:         JCastro
        Creation Date:  03/05/2019
        Purpose/Change: Desarrollo de la función inicial
    #>

    param(
    [Parameter(Mandatory)]
    [string]$user,

    [Parameter(Mandatory)]
    [string]$password,

    [Parameter(Mandatory)]
    [string]$fromEmail
    )

    # Obtiene credenciales seguras del correo electr�nico
    $SecurePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($user, $SecurePassword)
    #$Credentials = New-Object -TypeName System.Management.Automation -ArgumentList $user, $password

    # Entra a gmail para leer el correo
    $Gmail = New-GmailSession -Credential $cred # Crea una sesi�n de email

    try{
        $Inbox = $Gmail | Get-Mailbox # obtenga la bandeja de entrada
        $Message = $inbox | Get-Message -From $fromEmail -Prefetch -Unread | Select-Object -Last 1
        $Body = $Message.Body
        if(![string]::IsNullOrEmpty($Body)){
            $Message = $inbox | Get-Message -From $fromEmail -Prefetch -Unread | Update-Message -Read
        }
    }
    catch{
        $Body = 'Mensaje esta demorando en llegar...'
    }

    return $Body
}