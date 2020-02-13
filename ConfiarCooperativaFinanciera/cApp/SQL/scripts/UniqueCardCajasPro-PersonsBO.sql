-- SELECT TOP (1000) IdPerson
--       ,PersonCode
--       ,IdIdentificationType
--       ,PersonIdentification
--       ,IdProduct
--       ,Name
--       ,LastName
--       ,CardLabel
--       ,MagneticStripName
--       ,Telephone
--       ,Address
--       ,IdCity
--       ,Email
--       ,CreationDate
--       ,IdCreationUser
--       ,LastUpdate
--       ,IdLastUpdateUser
--       ,IdTimer
--       ,IdFile
--   FROM UniqueCardCajasPro.dbo.PersonsBO order by LastUpdate
SELECT TOP (1000) IdPerson
      ,IdIdentificationType
      ,PersonIdentification
      ,IdProduct
      ,Name
      ,LastName
      ,CardLabel
      ,MagneticStripName
      ,Telephone
      ,Address
      ,IdCity
      ,CreationDate
      ,LastUpdate
      ,IdLastUpdateUser
FROM PersonsBO
Where PersonIdentification like '{0}'