SELECT message_type
      , original_correlation_id
      , tran_type
      , from_account
      , to_account
      , amount
      , acquiring_inst_id
      , authorization_number
      , card_acceptor
      , ret_reference_number
FROM transactionlog
WHERE original_correlation_id like '%{0}'