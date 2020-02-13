
SELECT
    AuthorizationNumber,
    MessageType,
    TransactionType,
    ExtendedTransactionType,
    AmountTransaction,
    Pan,
    IdAcquirer,
    IdCardAcceptor,
    FromAccountType,
    ResponseCode
FROM TransactionsRT
WHERE  IdCard = '{0}'
    AND ReferenceNumber = '{1}'