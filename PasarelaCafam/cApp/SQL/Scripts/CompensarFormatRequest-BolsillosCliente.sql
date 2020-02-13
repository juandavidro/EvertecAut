SELECT art.IdAccountType, art.DeltaLedgerBalance
FROM CardsRT crt
    INNER JOIN CardAccountRT car on crt.IdCard = car.IdCard
    INNER JOIN AccountsRT art ON car.IdAccount = art.IdAccount
WHERE crt.IdCard = '{0}'
    AND crt.IdCard > 1000
    AND art.IdAccountType IN (80,81,82,83)