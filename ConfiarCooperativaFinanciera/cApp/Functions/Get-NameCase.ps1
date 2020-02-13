Function Get-NameCase {

    param (
        [string]$Novelty,
        [string]$TransactionName,
        [string]$TypeCase,
        [int]$NumberCase
    )

    if ($Novelty) {
        return $ConfiarCases.Transaction.$TransactionName.Novedades.$Novelty.$TypeCase.$NumberCase    
    }
    else {
        return $ConfiarCases.Transaction.$TransactionName.$TypeCase.$NumberCase
    }
}