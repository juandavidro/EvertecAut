SELECT TOP(1)
    it.Acronym,
    pbo.PersonIdentification,
    crt.IdCard,
    crt.Pan,
    pbo.CardLabel,
    cbo.CustomerGroup,
	art.IdAccountType, 
	art.DeltaLedgerBalance
FROM PersonsBO pbo
	INNER JOIN IdentificationTypes it ON pbo.IdIdentificationType = it.IdIdentificationType
    INNER JOIN CustomersBO cbo ON cbo.IdPerson = pbo.IdPerson
    INNER JOIN CardsRT crt ON crt.IdCustomer = cbo.IdCustomer
	INNER JOIN CardAccountRT car on crt.IdCard = car.IdCard
    INNER JOIN AccountsRT art ON car.IdAccount = art.IdAccount
WHERE pbo.PersonIdentification IS NOT NULL
    AND pbo.IdProduct = 1
    AND crt.HoldResponse IS NULL
    AND crt.State = 1
    AND pbo.email IS NOT NULL
	AND art.IdAccountType = 81
	AND art.DeltaLedgerBalance = 0
ORDER BY NEWID() DESC