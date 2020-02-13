DECLARE

@IdentificationType VARCHAR(3),
@PersonIdentification VARCHAR(50),
@IdCard INT,
@Pan VARCHAR(20),
@CardLabel VARCHAR(50),
@CustomerGroup VARCHAR(2),
@AccountType INT,
@Balance INT,
@i INT

set @i = 1

BEGIN
    CREATE TABLE #TablaCompra
    (
        IdentificationType VARCHAR(3),
        PersonIdentification varchar(50),
        IdCard INT,
        Pan VARCHAR(20),
        CardLabel VARCHAR(50),
        CustomerGroup VARCHAR(2),
        AccountType INT,
        Balance INT,
    )

    WHILE @i <= 12

    BEGIN
        SELECT
            @IdentificationType = it.Acronym,
            @PersonIdentification= pbo.PersonIdentification,
            @IdCard = crt.IdCard,
            @Pan = crt.Pan,
            @CardLabel = pbo.CardLabel,
            @CustomerGroup = cbo.CustomerGroup,
            @AccountType = art.IdAccountType,
            @Balance = art.DeltaLedgerBalance
        FROM PersonsBO pbo
            INNER JOIN IdentificationTypes it ON pbo.IdIdentificationType = it.IdIdentificationType
            INNER JOIN CustomersBO cbo ON cbo.IdPerson = pbo.IdPerson
            INNER JOIN CardsRT crt ON crt.IdCustomer = cbo.IdCustomer
            INNER JOIN CardAccountRT car on crt.IdCard = car.IdCard
            INNER JOIN AccountsRT art ON car.IdAccount = art.IdAccount
        WHERE pbo.IdIdentificationType = @i
            AND pbo.PersonIdentification IS NOT NULL
            AND pbo.IdProduct = 1
            AND crt.HoldResponse IS NULL
            AND crt.State = 1
            AND pbo.email = 'sendtokens@gmail.com'
            AND art.IdAccountType = 80
            AND crt.IdCard > 1000
        ORDER BY NEWID() DESC

        SET @i = @i + 1;

        INSERT INTO #TablaCompra
        VALUES
            ( @IdentificationType, @PersonIdentification, @IdCard, @Pan, @CardLabel, @CustomerGroup, @AccountType, @Balance)
    END

    SELECT *
    FROM #TablaCompra

END