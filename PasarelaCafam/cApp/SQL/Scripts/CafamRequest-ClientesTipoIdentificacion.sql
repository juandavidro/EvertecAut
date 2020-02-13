DECLARE

@IdentificationType VARCHAR(3),
@PersonIdentification VARCHAR(50),
@IdCard INT,
@Pan VARCHAR(20),
@CardLabel VARCHAR(50),
@CustomerGroup VARCHAR(2),
@i INT

set @i = 1

BEGIN

    CREATE TABLE #TablaTemporal
    (

        IdentificationType VARCHAR(3),
        PersonIdentification varchar(50),
        IdCard INT,
        Pan VARCHAR(20),
        CardLabel VARCHAR(50),
        CustomerGroup VARCHAR(2)

    )

    WHILE @i <= 12

BEGIN
        SELECT
            @IdentificationType = it.Acronym,
            @PersonIdentification= pbo.PersonIdentification,
            @IdCard = crt.IdCard,
            @Pan = crt.Pan,
            @CardLabel = pbo.CardLabel,
            @CustomerGroup = cbo.CustomerGroup

        FROM PersonsBO pbo
            INNER JOIN IdentificationTypes it ON pbo.IdIdentificationType = it.IdIdentificationType
            INNER JOIN CustomersBO cbo ON cbo.IdPerson = pbo.IdPerson
            INNER JOIN CardsRT crt ON crt.IdCustomer = cbo.IdCustomer

        WHERE pbo.IdIdentificationType = @i

            AND pbo.PersonIdentification IS NOT NULL
            AND pbo.IdProduct = 1
            AND crt.HoldResponse IS NULL
            AND pbo.email = 'sendtokens@gmail.com'

        ORDER BY NEWID() DESC

        SET @i = @i + 1;

 

        INSERT INTO #TablaTemporal

        VALUES

            ( @IdentificationType, @PersonIdentification, @IdCard, @Pan, @CardLabel, @CustomerGroup)

    END

 

    SELECT *

    FROM #TablaTemporal

END

 