SELECT art.DeltaLedgerBalance
FROM CardsRT crt
    INNER JOIN CardAccountRT car on crt.IdCard = car.IdCard
    INNER JOIN AccountsRT art ON car.IdAccount = art.IdAccount
WHERE crt.IdCard = '{0}'
    AND art.IdAccountType = '{1}'