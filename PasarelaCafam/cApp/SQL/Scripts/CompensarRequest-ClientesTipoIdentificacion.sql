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

    WHILE @i <= 14

BEGIN


    SELECT

            @IdentificationType = CASE

        WHEN pbo.IdIdentificationType = 1 THEN 'CC'
        WHEN pbo.IdIdentificationType = 2 THEN 'PAS'
        WHEN pbo.IdIdentificationType = 3 THEN 'TI'
        WHEN pbo.IdIdentificationType = 4 THEN 'CE'        
        WHEN pbo.IdIdentificationType = 5 THEN 'NJ'
        WHEN pbo.IdIdentificationType = 6 THEN 'PA'
        WHEN pbo.IdIdentificationType = 7 THEN 'RC'
        WHEN pbo.IdIdentificationType = 8 THEN 'NU'
        WHEN pbo.IdIdentificationType = 9 THEN 'NE'        
        WHEN pbo.IdIdentificationType = 10 THEN 'CO'
        WHEN pbo.IdIdentificationType = 11 THEN 'RUT'        
        WHEN pbo.IdIdentificationType = 12 THEN 'PEP'
        WHEN pbo.IdIdentificationType = 13 THEN 'CD'        
        WHEN pbo.IdIdentificationType = 14 THEN 'SP'

   END,  

        
           
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

 