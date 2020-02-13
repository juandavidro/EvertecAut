DECLARE

@IdentificationType VARCHAR(3),
@PersonIdentification VARCHAR(50),
@IdCard INT,
@Pan VARCHAR(20),
@CardLabel VARCHAR(50),
@CustomerGroup VARCHAR(2),
@StateCard VARCHAR(1),
@i INT

set @i = 3

BEGIN

    CREATE TABLE #TablaTemporal
    (

        IdentificationType VARCHAR(3),
        PersonIdentification varchar(50),
        IdCard INT,
        Pan VARCHAR(20),
        CardLabel VARCHAR(50),
        CustomerGroup VARCHAR(2),
        StateCard VARCHAR(1)

    )

    WHILE @i <= 7

BEGIN

        SELECT

            @IdentificationType = CASE

        WHEN pbo.IdIdentificationType = 3 THEN 'TI'
        WHEN pbo.IdIdentificationType = 4 THEN 'CC'
        WHEN pbo.IdIdentificationType = 5 THEN 'CE'
        WHEN pbo.IdIdentificationType = 6 THEN 'NIT'        
        WHEN pbo.IdIdentificationType = 7 THEN 'PAS'

        END,

            @PersonIdentification= pbo.PersonIdentification,
            @IdCard = crt.IdCard,
            @Pan = crt.Pan,
            @CardLabel = pbo.CardLabel,
            @CustomerGroup = cbo.CustomerGroup,
            @StateCard = crt.State

        FROM PersonsBO pbo

            INNER JOIN CustomersBO cbo ON cbo.IdPerson = pbo.IdPerson
            INNER JOIN CardsRT crt ON crt.IdCustomer = cbo.IdCustomer

        WHERE pbo.IdIdentificationType = @i

            AND pbo.PersonIdentification IS NOT NULL
            AND pbo.IdProduct = 1
            AND crt.HoldResponse IS NOT NULL
            AND pbo.email = 'sendtokens@gmail.com'
            AND crt.State = 0

        ORDER BY NEWID() DESC

        SET @i = @i + 1;

 

        INSERT INTO #TablaTemporal

        VALUES

            ( @IdentificationType, @PersonIdentification, @IdCard, @Pan, @CardLabel, @CustomerGroup, @StateCard)

    END

 

    SELECT TOP(1) *
    FROM #TablaTemporal
    WHERE StateCard = 0

END

 