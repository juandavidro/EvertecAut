
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
    ToAccountType,
    ResponseCode
FROM TransactionsRT
WHERE  IdCard = '{0}'
    AND AuthorizationNumber = '{1}'