# automatizaciones

Status automatization scripts

El objetivo de esta automatizacion es probar la generacion de mas de una tajeta
para un cliente con el mismo BIN. para el desarrollo se utilizan los siguientes modulos de powershell

	* Aspen.Autonomous
	* Aspen.Autonomous
	* Mdbc
	* Pester
	* PowerShellGet
	* Pscx
	* PSProcessa
	* Selenium
	* WinSCP

Es una ejecucion del proyecto de pruebas creado en testlink: 
	* CFR Confiar cooperativa financiera
En el plan de pruebas :
	* WBS3.1-35244  Certificación Confiar - Tarjetas del mismo BIN Crédito

Nota:  no se sigue la secuencia del plan de pruebas ya que esta no se a probado en su totalidad

Dentro de la automatizacion se generar los siguientes procedimientos:

Automatizacion_Cargue_Clientes.Tests
	* Crear un cliente en el portal BanckBu (Set-NewUser)
	* Hacer una solicitud de un credito Nuevo en el portal BanckBu (Get-Creditrequest)
	* Avanzar las solicitudes de nuevos plasticos (Set-RequestByStep)
	* Realzar los plasticos al ftp de confiar (Set-PlasticsAdmin)
	* Mover los archivos a los servidores respectivos (Copy-FileServerToServer)
	* Ejecutar Job para el realce de las tarjetas a TUP (Start-ConfiarLoadClient)

Automatizacion_Realce.Tests
	Se realzan los plasticos directamente de archivos locales a TUP (sin pasar por el portal)
	* Mover los archivos a los servidores respectivos (Copy-FileServerToServer)
	* Ejecutar Job para el realce de las tarjetas a TUP (Start-ConfiarLoadClient)

Automatizacion_Cargue_Bloqueos.Tests
	Se realizan los bloqueos de cliente desde el archivo en la ruta:
	"\ConfiarCooperativaFinanciera\Evidencias\LoadLock\BLOQUEOS_MASIVOS.txt""
	* Se copia el archivo al sftp (para ejecutar el proceso de cargue bloqueos masivos)
	* Se bloquea el cliente desde el portal de BanckBu (Lock-Client)
	* Se bloquea el cliente en TUP (Lock-TupClient)

Automatizacion_Tarjeta_Con_Mismo_Bin
	* Se verifica que exista el cliente con tarjeta con bloqueo definitivo (falta la verificacion del bloqueo)
	* Se genera la solicitud de nuevo credito (Get-Creditrequest)
	* Se avanzan las solicitudes de credito (Set-RequestByStep)
	* Se realza el plastico al ftp confiar (Set-PlasticsAdmin)
	* Se copian losarchivos a los servidores sftp correspondientes (Copy-FileServerToServer)
	* Se ejecuta el Job de cargue clientes (Start-ConfiarLoadClient)
	* Faltan validaciones

	* Se verifica que exista el cliente con tarjeta con bloqueo no definitivo (falta la verificacion del bloqueo)
	* Se genera la solicitud de nuevo credito (Get-Creditrequest)	
	* Faltan validaciones

Se dejan dcumentadas las funciones desarrolladas dentro de la carpeta:
	ConfiarCooperativaFinanciera/cApp/Funciones

Con ejemplos.

	


