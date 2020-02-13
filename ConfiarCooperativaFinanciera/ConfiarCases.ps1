@{
   	Transaction = @{
		CargueClientes = @{
			Novedades = @{
				NovedadI = @{
					Exito = @{
						1 = 'CFR-902 :: Versión : 1 :: Cargue clientes novedad I'
						2 = 'CFR-903 :: Versión : 1 :: Cargue clientes Tipo de Id diferente, mismo No. Identificación.'
					}
					Excepcion = @{
						1 = 'CFR-904 :: Versión : 1 :: Cargue clientes novedad en minúscula.'
						2 = 'CFR-905 :: Versión : 1 :: Cargue cliente código único de cliente vacío.'
						3 = 'CFR-906 :: Versión : 1 :: Cargue cliente código único de cliente formato texto.'
						4 = 'CFR-907 :: Versión : 1 :: Cargue cliente código único de cliente longitud >25.'
						5 = 'CFR-908 :: Versión : 1 :: Cargue cliente código único de cliente repetido.'
						6 = 'CFR-910 :: Versión : 1 :: Cargue clientes Tipo de Id inexistente en DB.'
						7 = 'CFR-912 :: Versión : 1 :: Cargue clientes Tipo de Id Vacío.'
						8 = 'CFR-913 :: Versión : 1 :: Cargue clientes Tipo de Id formato texto.'
						9 = 'CFR-914 :: Versión : 1 :: Cargue clientes identificación vacía.'
					}
				}
				NovedadP = @{
					Exito = @{
						1 = 'CFR-938 :: Versión : 1 :: Cargue clientes novedad P'
						2 = 'CFR-939 :: Versión : 1 :: Actualizar apellidos.'
						3 = 'CFR-940 :: Versión : 1 :: Actualizar nombres.'
						4 = 'CFR-941 :: Versión : 1 :: Actualizar nombre para realce.'
						5 = 'CFR-942 :: Versión : 1 :: Actualizar teléfono de contacto.'
						6 = 'CFR-943 :: Versión : 1 :: Actualizar cuenta de correo.'
						7 = 'CFR-944 :: Versión : 1 :: Actualizar dirección.'
						8 = 'CFR-945 :: Versión : 1 :: Actualizar Código ciudad DANE.'
					}
					Excepcion = @{
						# 1 = 'CFR-946 :: Versión : 1 :: Cargue clientes novedad en minúscula.'
						# 2 = 'CFR-947 :: Versión : 1 :: Cargue cliente código único de cliente vacío.'
						# 3 = 'CFR-948 :: Versión : 1 :: Cargue cliente código único de cliente no existente en BD.'
						# 4 = 'CFR-949 :: Versión : 1 :: Actualizar campos no permitidos por la novedad.'
						# 5 = 'CFR-950 :: Versión : 1 :: Actualizar campos permitidos por la novedad.'
						# 6 = 'CFR-951 :: Versión : 1 :: Actualizar con código único de cliente Repetido.'
						# 7 = 'CFR-952 :: Versión : 1 :: Actualizar con No. Identificación repetido.'
						# 8 = 'CFR-953 :: Versión : 1 :: Actualizar con No. Identificación no existente en BD.'
						# 9 = 'CFR-954 :: Versión : 1 :: Actualizar con No. Identificación Vacío.'
					}
				}
				NovedadU = @{
					Exito = @{
						1 = 'CFR-965 :: Versión : 1 :: Cargue clientes novedad U.'
						# 2 = 'CFR-966 :: Versión : 1 :: novedad U nombres.'
						# 3 = 'CFR-967 :: Versión : 1 :: novedad U apellidos.'
						# 4 = 'CFR-968 :: Versión : 1 :: novedad U nombre para realce.'
						# 5 = 'CFR-969 :: Versión : 1 :: novedad U teléfono de contacto.'
						# 6 = 'CFR-970 :: Versión : 1 :: novedad U cuenta de correo.'
						# 7 = 'CFR-971 :: Versión : 1 :: novedad U dirección.'
						# 8 = 'CFR-972 :: Versión : 1 :: novedad U Código ciudad DANE.'
					}
					# Excepcion = @{
						# 1 = 'CFR-973 :: Versión : 1 :: Cargue clientes novedad en minúscula.'
						# 2 = 'CFR-974 :: Versión : 1 :: Cargue cliente código único de cliente vacío.'
						# 3 = 'CFR-975 :: Versión : 1 :: Cargue cliente código único de cliente no existente en BD.'
						# 4 = 'CFR-976 :: Versión : 1 :: novedad U campos no permitidos por la novedad.'
						# 5 = 'CFR-977 :: Versión : 1 :: novedad U campos permitidos por la novedad.'
						# 6 = 'CFR-978 :: Versión : 1 :: novedad U nombres.'
						# 7 = 'CFR-979 :: Versión : 1 :: novedad U apellidos.'
						# 8 = 'CFR-980 :: Versión : 1 :: novedad U nombre para realce.'
						# 9 = 'CFR-981 :: Versión : 1 :: novedad U teléfono de contacto.'
					# }
				}
				# NovedadR = @{
					# Exito = @{
						# 1 = 'CFR-999 :: Versión : 1 :: Novedad R generar nueva tarjeta.'
						# 2 = 'CFR-1000 :: Versión : 1 :: Reexpedición con bloqueo 41.'
						# 3 = 'CFR-1001 :: Versión : 1 :: Reexpedición con bloqueo 43.'
						# 4 = 'CFR-1002 :: Versión : 1 :: Reexpedición con bloqueo 59.'
						# 5 = 'CFR-1003 :: Versión : 1 :: Reexpedición con bloqueo NO.'
						# 6 = 'CFR-1004 :: Versión : 1 :: Reexpedición con bloqueo OH.'
						# 7 = 'CFR-1005 :: Versión : 1 :: Reexpedición con bloqueo OW.'
						# 8 = 'CFR-1006 :: Versión : 1 :: Reexpedición con bloqueo OY.'
						# 9 = 'CFR-1007 :: Versión : 1 :: Reexpedición con bloqueo OZ.'
						# 10 = 'CFR-1008 :: Versión : 1 :: Reexpedición con bloqueo Q2.'
						# 11 = 'CFR-1009 :: Versión : 1 :: Reexpedición con bloqueo Q6'
						# 12 = 'CFR-1010 :: Versión : 1 :: Reexpedición con bloqueo Q9.'
						# 13 = 'CFR-1011 :: Versión : 1 :: Reexpedición con bloqueo QA.'
						# 14 = 'CFR-1012 :: Versión : 1 :: Reexpedición con bloqueo QB.'
						# 15 = 'CFR-1013 :: Versión : 1 :: Reexpedición con bloqueo QD.'
					# }
					# Excepcion = @{
						# 1 = 'CFR-1015 :: Versión : 1 :: Reexpedición con bloqueo OX.'
						# 2 = 'CFR-1016 :: Versión : 1 :: Reexpedición con bloqueo P1.'
						# 3 = 'CFR-1017 :: Versión : 1 :: Reexpedición con bloqueo Q3.'
						# 4 = 'CFR-1018 :: Versión : 1 :: Reexpedición con bloqueo Q4.'
						# 5 = 'CFR-1019 :: Versión : 1 :: Reexpedición con bloqueo Q5.'
						# 6 = 'CFR-1020 :: Versión : 1 :: Reexpedición con bloqueo Q7.'
						# 7 = 'CFR-1021 :: Versión : 1 :: Reexpedición con bloqueo QC.'
						# 8 = 'CFR-1022 :: Versión : 1 :: Reexpedición con bloqueo QE.'
						# 9 = 'CFR-1023 :: Versión : 1 :: Reexpedición con bloqueo QF.'
					# }
				# }
				# NovedadT = @{
				# 	Exito = @{
						# 1 = 'CFR-1051 :: Versión : 1 :: Reposición con bloqueo 41.'
						# 2 = 'CFR-1052 :: Versión : 1 :: Reposición con bloqueo 43.'
						# 3 = 'CFR-1053 :: Versión : 1 :: Reposición con bloqueo 59.'
						# 4 = 'CFR-1054 :: Versión : 1 :: Reposición con bloqueo NO.'
						# 5 = 'CFR-1055 :: Versión : 1 :: Reposición con bloqueo OH.'
						# 6 = 'CFR-1056 :: Versión : 1 :: Reposición con bloqueo OV.'
						# 7 = 'CFR-1057 :: Versión : 1 :: Reposición con bloqueo OW.'
						# 8 = 'CFR-1058 :: Versión : 1 :: Reposición con bloqueo OX.'
						# 9 = 'CFR-1059 :: Versión : 1 :: Reposición con bloqueo OY.'
						# 10 = 'CFR-1060 :: Versión : 1 :: Reposición con bloqueo OZ.'
						# 11 = 'CFR-1061 :: Versión : 1 :: Reposición con bloqueo Q2.'
						# 12 = 'CFR-1062 :: Versión : 1 :: Reposición con bloqueo Q6.'
						# 13 = 'CFR-1063 :: Versión : 1 :: Reposición con bloqueo Q9.'
						# 14 = 'CFR-1064 :: Versión : 1 :: Reposición con bloqueo QA.'
						# 15 = 'CFR-1065 :: Versión : 1 :: Reposición con bloqueo QB.'
						# 16 = 'CFR-1066 :: Versión : 1 :: Reposición con bloqueo QD.'
						# 17 = 'CFR-1067 :: Versión : 1 :: Reposición con bloqueo JB.'
						# 18 = 'CFR-1068 :: Versión : 1 :: Cargue clientes Reposición.'
						# 19 = 'CFR-1069 :: Versión : 1 :: Actualizar campos permitidos por la novedad.'
						# 20 = 'CFR-1070 :: Versión : 1 :: Actualizar nombres.'
						# 21 = 'CFR-1071 :: Versión : 1 :: Actualizar apellidos.'
						# 22 = 'CFR-1072 :: Versión : 1 :: Actualizar nombre para realce.'
						# 23 = 'CFR-1073 :: Versión : 1 :: Actualizar teléfono de contacto.'
						# 24 = 'CFR-1074 :: Versión : 1 :: Actualizar cuenta de correo.'
						# 25 = 'CFR-1075 :: Versión : 1 :: Actualizar dirección.'
						# 26 = 'CFR-1076 :: Versión : 1 :: Actualizar Código ciudad DANE.'
					# }
					# Excepcion = @{
						# 1 = 'CFR-1077 :: Versión : 1 :: Reposición con bloqueo 57.'
						# 2 = 'CFR-1078 :: Versión : 1 :: Reposición con bloqueo 62.'
						# 3 = 'CFR-1079 :: Versión : 1 :: Reposición con bloqueo NP.'
						# 4 = 'CFR-1080 :: Versión : 1 :: Reposición con bloqueo NQ.'
						# 5 = 'CFR-1081 :: Versión : 1 :: Reposición con bloqueo OF.'
						# 6 = 'CFR-1082 :: Versión : 1 :: Reposición con bloqueo P1.'
						# 7 = 'CFR-1083 :: Versión : 1 :: Reposición con bloqueo Q1.'
						# 8 = 'CFR-1084 :: Versión : 1 :: Reposición con bloqueo Q3.'
						# 9 = 'CFR-1085 :: Versión : 1 :: Reposición con bloqueo Q4.'
						# 10 = 'CFR-1086 :: Versión : 1 :: Reposición con bloqueo Q5.'
						# 11 = 'CFR-1087 :: Versión : 1 :: Reposición con bloqueo Q7.'
						# 12 = 'CFR-1088 :: Versión : 1 :: Reposición con bloqueo QC.'
						# 13 = 'CFR-1089 :: Versión : 1 :: Reposición con bloqueo QE.'
						# 14 = 'CFR-1090 :: Versión : 1 :: Reposición con bloqueo QF.'
						# 15 = 'CFR-1091 :: Versión : 1 :: Reposición con bloqueo QG.'
						# 16 = 'CFR-1092 :: Versión : 1 :: Reposición con bloqueo JA.'
						# 17 = 'CFR-1093 :: Versión : 1 :: Reposición con bloqueo BB.'
					# }
				# }
				NovedadM = @{
					Exito = @{
						1 = 'CFR-1112 :: Versión : 1 :: Cargue cliente Novedad M'
					}
					# Excepcion = @{
						# 1 = 'CFR-1113 :: Versión : 1 :: Novedad M campo novedad vacío.'
						# 2 = 'CFR-1114 :: Versión : 1 :: novedad M Código cliente incorrecta.'
						# 3 = 'CFR-1115 :: Versión : 1 :: novedad M Código cliente vacío.'
						# 4 = 'CFR-1116 :: Versión : 1 :: novedad M Tipo de Id incorrecta.'
						# 5 = 'CFR-1117 :: Versión : 1 :: novedad M Tipo de Id vacío.'
						# 6 = 'CFR-1118 :: Versión : 1 :: novedad M No. Identificación incorrecta.'
						# 7 = 'CFR-1119 :: Versión : 1 :: novedad M No. Identificación vacío.'
						# 8 = 'CFR-1120 :: Versión : 1 :: novedad M nombres incorrectos.'
						# 9 = 'CFR-1121 :: Versión : 1 :: novedad M nombres vacíos.'
					# }
				}
				# NovedadW = @{
					# Exito = @{
						# 1 = 'CFR-1136 :: Versión : 1 :: Renovación con bloqueo 41.'
						# 2 = 'CFR-1137 :: Versión : 1 :: Renovación con bloqueo 43.'
						# 3 = 'CFR-1138 :: Versión : 1 :: Renovación con bloqueo 59.'
						# 4 = 'CFR-1139 :: Versión : 1 :: Renovación con bloqueo 62.'
						# 5 = 'CFR-1140 :: Versión : 1 :: Renovación con bloqueo NQ.'
						# 6 = 'CFR-1141 :: Versión : 1 :: Renovación con bloqueo OV.'
						# 7 = 'CFR-1142 :: Versión : 1 :: Renovación con bloqueo OW.'
						# 8 = 'CFR-1143 :: Versión : 1 :: Renovación con bloqueo OX.'
						# 9 = 'CFR-1144 :: Versión : 1 :: Renovación con bloqueo OY.'
						# 10 = 'CFR-1145 :: Versión : 1 :: Renovación con bloqueo P1.'
						# 11 = 'CFR-1146 :: Versión : 1 :: Renovación con bloqueo Q1.'
						# 12 = 'CFR-1147 :: Versión : 1 :: Renovación con bloqueo Q3.'
						# 13 = 'CFR-1148 :: Versión : 1 :: Renovación con bloqueo Q4.'
						# 14 = 'CFR-1149 :: Versión : 1 :: Renovación con bloqueo Q5.'
						# 15 = 'CFR-1150 :: Versión : 1 :: Renovación con bloqueo Q6.'
						# 16 = 'CFR-1151 :: Versión : 1 :: Renovación con bloqueo Q7.'
						# 17 = 'CFR-1152 :: Versión : 1 :: Renovación con bloqueo QA.'
						# 18 = 'CFR-1153 :: Versión : 1 :: Renovación con bloqueo QC.'
						# 19 = 'CFR-1154 :: Versión : 1 :: Renovación con bloqueo QE.'
						# 20 = 'CFR-1155 :: Versión : 1 :: Renovación con bloqueo QF.'
						# 21 = 'CFR-1156 :: Versión : 1 :: Renovación con bloqueo JB.'
						# 22 = 'CFR-1157 :: Versión : 1 :: Renovación con bloqueo BB'
					# }
					# Excepcion = @{
						# 1 = 'CFR-1176 :: Versión : 1 :: Renovación con bloqueo 57.'
						# 2 = 'CFR-1177 :: Versión : 1 :: Renovación con bloqueo NO.'
						# 3 = 'CFR-1178 :: Versión : 1 :: Renovación con bloqueo NP.'
						# 4 = 'CFR-1179 :: Versión : 1 :: Renovación con bloqueo OF.'
						# 5 = 'CFR-1180 :: Versión : 1 :: Renovación con bloqueo OH.'
						# 6 = 'CFR-1181 :: Versión : 1 :: Renovación con bloqueo OZ.'
						# 7 = 'CFR-1182 :: Versión : 1 :: Renovación con bloqueo Q2.'
						# 8 = 'CFR-1183 :: Versión : 1 :: Renovación con bloqueo Q9.'
						# 9 = 'CFR-1184 :: Versión : 1 :: Renovación con bloqueo QB.'
						# 10 = 'CFR-1185 :: Versión : 1 :: Renovación con bloqueo QD.'
						# 11 = 'CFR-1186 :: Versión : 1 :: Renovación con bloqueo JA.'
						# 12 = 'CFR-1187 :: Versión : 1 :: Cargue clientes Renovación.'
					# }
				# }
			}
		}
		CargueBloqueos = @{
			Exito = @{
				1 = 'CFR-898 :: Versión : 1 :: Cargue bloqueo correcto.'
			}
			Excepcion = @{
				1 = 'CFR-873 :: Versión : 1 :: Cargue bloqueo con registros duplicados.'
				2 = 'CFR-874 :: Versión : 1 :: Cargue bloqueos con registros duplicados diferente concepto.'
				# 3 = 'CFR-875 :: Versión : 1 :: Cargue bloqueo nombre incorrecto del archivo.'
				# 4 = 'CFR-876 :: Versión : 1 :: Cargue Bloqueos encabezado Incorrecto Empresa'
				# 5 = 'CFR-877 :: Versión : 1 :: Cargue Bloqueos encabezado Incorrecto Fecha'
				# 6 = 'CFR-878 :: Versión : 1 :: Cargue bloqueos encabezado incorrecto Contador'
				# 7 = 'CFR-879 :: Versión : 1 :: Cargue bloqueos encabezado incorrecto INN + IIN'
			}
		}
		IVR = @{	
			Exito = @{
				1 = 'CFR-863 :: Versión : 1 :: Activación de tarjeta registrada en BD.'
				# 2 = 'CFR-864 :: Versión : 1 :: Activación de tarjeta creada con Novedad M.'
			}
			Excepcion = @{
				1 = 'CFR-861 :: Versión : 1 :: Activación de tarjeta no registrada en BD.'
				2 = 'CFR-862 :: Versión : 1 :: Activación de tarjeta con No. Identificación inexistente en BD.'
				3 = 'CFR-865 :: Versión : 1 :: Activación de tarjeta con bloqueo general.'
				4 = 'CFR-866 :: Versión : 1 :: Activación de tarjeta con bloqueo definitivo.'
				5 = 'CFR-867 :: Versión : 1 :: Activación de tarjeta ya activa.'
				6 = 'CFR-868 :: Versión : 1 :: Activación de tarjeta con Pin <4 dígitos.'
				7 = 'CFR-869 :: Versión : 1 :: Activación de tarjeta con Pin >4 dígitos.'
				8 = 'CFR-870 :: Versión : 1 :: Activación de tarjeta con confirmación de Pin incorrecto.'
				9 = 'CFR-871 :: Versión : 1 :: Activación de tarjeta con confirmación de Pin sin respuesta.'
				10 = 'CFR-872 :: Versión : 1 :: Activación de tarjeta con Pin sin respuesta.'
			}
		}
		
		GenerarTarjetaConMismoBIN = @{
			ClienteConUnaTarjetaCancelada = @{
				1 = 'CFR-1266 :: Versión : 1 :: Acceder al parámetro 494 y dejar el campo valor en blanco'
				2 = 'CFR-1266 :: Versión : 1 :: Acceder al parámetro 494 y dejar el campo valor en blanco'
				3 = 'CFR-1268 :: Versión : 1 :: Validar solicitudes por etapa'
				4 = 'CFR-1269 :: Versión : 1 :: Consultar solicitudes por etapa'
			}
			ClienteConSoloUnaTarjetaActiva = @{
				1 = 'CFR-1270 :: Versión : 1 :: Acceder al parámetro 494 y dejar el campo valor en blanco'
				2 = 'CFR-1271 :: Versión : 1 :: Generar solicitud de tarjeta con mismo BIN para un cliente con solo una tarjeta'
				3 = 'CFR-1272 :: Versión : 1 :: Validar solicitudes por etapa'
				4 = 'CFR-1273 :: Versión : 1 :: Consultar solicitudes por etapa'
			} 
			BloqueoDeTarjeta = @{
				1 = 'CFR-1275 :: Versión : 1 :: Bloquear cliente con bloqueo 22'
				2 = 'CFR-1276 :: Versión : 1 :: Bloquear cliente con bloqueo 53'
				# 3 = 'CFR-1277 :: Versión : 1 :: Bloquear cliente con bloqueo I'
				# 4 = 'CFR-1278 :: Versión : 1 :: Bloquear cliente con bloqueo K'
				# 5 = 'CFR-1279 :: Versión : 1 :: Bloquear cliente con bloqueo T'
				6 = 'CFR-1280 :: Versión : 1 :: Bloquear cliente con bloqueo V'
			}
			GenerarSolicitudNuevoBIN = @{
				# 1 = 'CFR-1281 :: Versión : 1 :: Generar solicitud de tarjeta con mismo BIN a un cliente con bloqueo 22'
				2 = 'CFR-1282 :: Versión : 1 :: Generar solicitud de tarjeta con mismo BIN a un cliente con bloqueo 53'
				3 = 'CFR-1283 :: Versión : 1 :: Generar solicitud de tarjeta con mismo BIN a un cliente con bloqueo I'
				# 4 = 'CFR-1284 :: Versión : 1 :: Generar solicitud de tarjeta con mismo BIN a un cliente con bloqueo K'
				# 5 = 'CFR-1285 :: Versión : 1 :: Generar solicitud de tarjeta con mismo BIN a un cliente con bloqueo T'
				6 = 'CFR-1286 :: Versión : 1 :: Generar solicitud de tarjeta con mismo BIN a un cliente con bloqueo V'
			}
		}
		ConsultaGeneral = @{
			Validaciones = @{
				1 = 'CMP-3224:Realizar Consulta de información general de la tarjeta'
				2 = 'CMP-3225:Realizar Consulta de información general de la tarjeta con No. identificación inexistente'
				3 = 'CMP-3226:Realizar Consulta de información general de la tarjeta con tipo de indentificación invalido'
				4 = 'CMP-3227:Realizar Consulta de información general de la tarjeta con campos vacios'
				5 = 'Caso no creado en TestLink:Realizar Consulta de información general de la tarjeta cliente sin bloqueo'
				6 = 'Caso no creado en TestLink:Realizar Consulta de información general de la tarjeta cliente con bloqueo'
				7 = 'Caso no creado en TestLink:Realizar Consulta de información general de la tarjeta cliente con cupo rotativo'
				8 = 'Caso no creado en TestLink:Realizar Consulta de información general de la tarjeta cliente ficticio'
				9 = 'Caso no creado en TestLink:Realizar Consulta de información general de la tarjeta cliente sin tipo de identificación'
				10 = 'Caso no creado en TestLink:Realizar Consulta de información general de la tarjeta cliente con acronimo que no se encuentra en el anexo'
			}
		}
		PinPad = @{
			PruebaExito = @{
				1 = 'CFR-1287 :: Versión : 1 :: Activacion tarjeta CLASICA GENERAL 525983'
				2 = 'CFR-1288 :: Versión : 1 :: Activacion tarjeta CLASICA MIGRACION 531124'
				3 = 'CFR-1289 :: Versión : 1 :: Activacion tarjeta CLASICA EMPRESARIAL 547780'
				4 = 'CFR-1290 :: Versión : 1 :: Activacion tarjeta GOLD GENERAL 550237'
				5 = 'CFR-1291 :: Versión : 1 :: Activacion tarjeta CLASICA GENERAL 525983'
				6 = 'CFR-1292 :: Versión : 1 :: Activacion tarjeta CLASICA MIGRACION 531124'
				7 = 'CFR-1293 :: Versión : 1 :: Activacion tarjeta CLASICA EMPRESARIAL 547780'
				8 = 'CFR-1294 :: Versión : 1 :: Activacion tarjeta GOLD GENERAL 550237'
			}
		}
		Realce = @{
			1 = 'CFR-1295 :: Versión : 1 :: Realce de Tarjetas'
		}
	}
 }