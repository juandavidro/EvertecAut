SELECT TOP(1) idt.Acronym, pbo.PersonIdentification, crt.Pan, crt.[State], crt.HoldResponse, pbo.Email, cbo.CustomerGroup FROM CustomersBO cbo

INNER JOIN CardsRT crt ON cbo.IdCustomer = crt.IdCustomer

INNER JOIN PersonsBO pbo ON cbo.IdPerson = pbo.IdPerson

INNER JOIN IdentificationTypes idt ON pbo.IdIdentificationType = idt.IdIdentificationType

where pbo.Email = 'sendtokens@gmail.com'
And crt.[State] = 1
AND pbo.PersonIdentification IS NOT NULL
AND pbo.IdProduct = 1
AND crt.HoldResponse IS NOT NULL
