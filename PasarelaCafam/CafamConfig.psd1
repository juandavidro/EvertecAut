@{
    UrlAspen = 'https://apiqa.processa.com:8082/api/app/'
	PathSignin = 'auth/signin'
	PathSolicitudToken = 'tokens/send'
	PathCompra = 'financial/payment'
	PathReversoCompra = 'financial/payment'
	PathAnulacionCompra = 'financial/refund'
	PathReversoAnulacion = 'financial/refund'
	ConnectionString = 'Server=192.168.60.57;Database=UniqueCardCafam;User Id=prf;Password=Tester2012*/;';
	ConnectionStringMicroservice = 'Server=192.168.60.210;Database=microservices;User Id=prf;Password=Tester2012*/;';
	AppSecret = 'WPuusQBY+EjFA4GqH5+gtteA1j/vD1LRxx3n5JIxe5nmK+KYxgdccxvLE+5ECedxa+FgH60CiZXgocdfLc71Qql8MlVlsk7C6gqH9GWkG7VqdRnGj5ku+Y/ZGIWv0Ukzbt1Nj4GIwdu1IhDkNVpY84cq'
	AppKey = '14e8ecee-9391-4428-aa4c-bb1be8c3c260'
	MongoConnectionString = 'mongodb://superAdmin:pass123@192.168.60.210:27017'
	MongoDatabase = 'logs'
	CollectionKraken = 'Processa.RabbitMQ.Services.Kraken'
	AcquirerPasarela = '22000000005'
	SftpConnection = @{
		Protocol='sftp'
		Host='192.168.60.100'
		Username='sftpqa'
		Password='C3rt1f1c4c10n'
		Fingerprint='ssh-rsa 2048 35:af:73:02:bd:4d:ca:64:94:e7:c8:76:3b:1f:38:f5'
	}
	CardAcceptor = @(
		'000000011029774',
		'000000014436950',
		'000000014437016',
		'000000014437032'
	)
	MessageWarning = 'Respuesta no deberia ser exitosa'

 }