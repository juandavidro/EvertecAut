SELECT message_type
      , tran_type
      , from_account
      , amount
      , acquiring_inst_id
      , authorization_number
      , card_acceptor
FROM transactionlog
where ret_reference_number = '{0}'