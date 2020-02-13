SELECT item_id
      ,IdFileType
      ,ProcessName
      ,Status
      ,Description
      ,CreationDate
  FROM LogsLoadFiles
  WHERE CreationDate >= '{0}'
  AND ProcessName like 'Processa.LoadFiles - Confiar.CustomerCardLoad'
  order by CreationDate