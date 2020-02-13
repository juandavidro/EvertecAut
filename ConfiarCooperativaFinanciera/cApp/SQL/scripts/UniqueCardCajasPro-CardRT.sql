  Select PersonIdentification, Name, LastName, Pan, State, HoldResponse , LastTransactionDate
  from(( CardsRT
  inner join CustomersBO on          CardsRT.IdCustomer = CustomersBO.IdCustomer
  inner join PersonsBO on CustomersBO.IdPerson = PersonsBO.IdPerson))
  where Pan = '{0}'