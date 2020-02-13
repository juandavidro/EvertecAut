SELECT message_type
      , tran_type
      , from_account
      , amount
      , acquiring_inst_id
      , authorization_number
      , card_acceptor
FROM transactionlog
WHERE authorization_number = '{0}'