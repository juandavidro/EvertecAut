function Get-AuthenticationToken {

    <#
	.SYNOPSIS
        Retorna el token de autenticación para realizar la petición de cualquier transacción.
    .DESCRIPTION
        Crea un objeto JWT con dos valores: El token de autenticación emitido para una aplicación y la fecha de vencimiento del mismo.
	.PARAMETER Parameter
		Nombre de identificación de las operaciones del cliente que se vayan a efectuar.
    .EXAMPLE
        Get-AuthenticationToken -Parameter 'Pasarela_'
    .NOTES
        Author:         JPeña
        Creation Date:  03/05/2019
        Purpose/Change: Desarrollo de la función inicial
    #>

    param (
        [Parameter()]
        [String]
        $Parameter
    )


    try {

        $ConnectSftp = 'protocol=' + $Config.SftpConnection.Protocol + ';host=' + $Config.SftpConnection.Host + ';username=' + $Config.SftpConnection.Username + ';password=' + $Config.SftpConnection.Password + ';fingerprint=' + $Config.SftpConnection.Fingerprint

        #Hace la petición al servidor para traer el archivo que contiene el token si ya se ha generado alguno
        $PatchFile = '/SFTPQA/TokenAspen/' + $Parameter + 'TokenServer.txt'
        $GetToken = $ConnectSftp | Copy-FileFromServer -LocalPath $PathToken -RemotePath $PatchFile
        $PathTokenServer = '.\cApp\' + $Parameter + 'TokenServer.txt'
        $ContentLineToken = (Get-Content -Path $PathTokenServer -TotalCount 2)[-2]
        $ContentLineExp = (Get-Content -Path $PathTokenServer -TotalCount 2)[-1]

        #calcula el tiempo transcurrido hasta la petición
        $epochTimeNow = Get-EpochTime

    }
    catch {

        $Response = $_.Exception.Message
        #Genera el Header para la invocacion de la operacion de autenticaci�n
        $Header = New-Header -AppSecret $Config.AppSecret -AppKey $Config.AppKey

        #Genera token de autenticaci�n invocando la operacion Signin
        $JWT = Invoke-RestMethod -Method 'Post' -Uri $PathSignin -Headers $Header

        #Deserializa el token obtenido en la autenticaci�n
        $DecodeJWT = $JWT | ConvertFrom-Jwt -AppSecret $Config.AppSecret

        #Invoca la función que almacena la evidencia del caso
        $SaveToken = $Parameter + 'TokenServer'
        Save-Token -Value1 $DecodeJWT.jti -Value2 $DecodeJWT.exp -PathToken $PathToken -Testtype $SaveToken
        $Filter = $Parameter + 'TokenServer.txt'
        $CopyFileToServer = $connectSftp | Copy-FileToServer -LocalFile (Get-ChildItem -Path $PathToken -Filter $Filter) -RemotePath '/SFTPQA/TokenAspen'
        $RemoveItem = $PathToken + '\' + $Parameter + 'TokenServer.txt'
        Remove-Item -Path $RemoveItem
        return $DecodeJWT.jti
    }


    if ($contentLineExp -And $contentLineExp -lt $epochTimeNow) {

        #Genera el Header para la invocacion de la operacion de autenticaci�n
        $Header = New-Header -AppSecret $Config.AppSecret -AppKey $Config.AppKey

        #Genera token de autenticaci�n invocando la operacion Signin
        $JWT = Invoke-RestMethod -Method 'Post' -Uri $PathSignin -Headers $Header

        #Deserializa el token obtenido en la autenticaci�n
        $DecodeJWT = $JWT | ConvertFrom-Jwt -AppSecret $Config.AppSecret

        #Invoca la función que almacena la evidencia del caso
        $SaveToken = $Parameter + 'TokenServer'
        Save-Token -Value1 $DecodeJWT.jti -Value2 $DecodeJWT.exp -PathToken $PathToken -Testtype $SaveToken
        $Filter = $Parameter + 'TokenServer.txt'
        $CopyFile = $connectSftp | Copy-FileToServer -LocalFile (Get-ChildItem -Path $PathToken -Filter $Filter) -RemotePath '/SFTPQA/TokenAspen'
        $RemoveItem = $PathToken + '\' + $Parameter + 'TokenServer.txt'
        Remove-Item -Path $RemoveItem

    }
    else {
        $RemoveItem = $PathToken + '\' + $Parameter + 'TokenServer.txt'
        Remove-Item -Path $RemoveItem
        return $contentLineToken

    }

    return $DecodeJWT.jti
}