
SELECT TOP (1)
    IdTransaction,
    AuthorizationNumber,
    MessageType,
    TransactionType,
    ExtendedTransactionType,
    AmountTransaction,
    Pan,
    IdAcquirer,
    IdCardAcceptor,
    FromAccountType,
    ResponseCode,
    ReferenceNumber
FROM TransactionsRT
WHERE  IdCard = '{0}' order by 1 desc
