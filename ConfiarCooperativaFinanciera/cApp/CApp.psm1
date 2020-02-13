#Requires -RunAsAdministrator

Set-StrictMode -Version Latest

try {

	#Cargar archivos de funciones personalizadas
	Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'Functions/*.ps1' -File | 
		Select-Object -ExpandProperty FullName | 
		ForEach-Object { . $_ }

	#Cargar archivos de inicialización, si existiera
	Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'SQL/*.ps1' -File | 
		Select-Object -ExpandProperty FullName | 
		ForEach-Object { . $_ } 
}
catch {
	throw    
}

