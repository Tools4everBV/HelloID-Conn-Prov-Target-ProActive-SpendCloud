##############################################
# HelloID-Conn-Prov-Target-SpendCloud-Update
##############################################

# Initialize default values
$database = $actionContext.Configuration.database

# Helper: escape single quotes for safe inclusion in SQL string literals
function ConvertTo-SqliteLiteral {
    param(
        [string]$Value
    )
    if ($null -eq $Value) { return $Value }
    return $Value -replace "'", "''"
}

try {
    # Create account object from mapped data and set the correct account reference
    $account = $actionContext.Data

    # Make sure module is imported
    Import-Module PSSQLite

    Write-Information "Verifying if DB row exists"
    $query = "SELECT * FROM persons WHERE gebruikersnaam = '$($actionContext.References.Account)'"
    $currentAccount = Invoke-SqliteQuery -Query $query -DataSource $database

    $previousAccount = [PSCustomObject]@{
        achternaam     = $currentAccount.achternaam
        tussenvoegsel  = $currentAccount.tussenvoegsel
        voornaam       = $currentAccount.voornaam
        gebruikersnaam = $currentAccount.gebruikersnaam
        geslacht       = $currentAccount.geslacht
        externalId     = $currentAccount.externalId
        email          = $currentAccount.email
        passief        = $currentAccount.passief
    }

    if ($null -eq $account.PSObject.Properties['passief']) {
        $account | Add-Member -MemberType NoteProperty -Name 'passief' -Value $null
    }

    # If the account was correlated, we need to clear the passief field, otherwise it will remain disabled
    if ($actionContext.AccountCorrelated -eq $true){
        $account.passief = $null
    } else {
        # If the account was not correlated, we need to set the passief field to the value from the current account
        $account.passief = $previousAccount.passief
    }

    # Calculate changes between current data and provided data
    $splatCompareProperties = @{
        ReferenceObject  = @($previousAccount.PSObject.Properties) # Only select the properties to update
        DifferenceObject = @($account.PSObject.Properties) # Only select the properties to update
    }

    $changedProperties = $null
    $changedProperties = (Compare-Object @splatCompareProperties -PassThru)

    $newProperties = $changedProperties.Where( { $_.SideIndicator -eq '=>' })

    if (($newProperties | Measure-Object).Count -ge 1) {
        $achternaam = ConvertTo-SqliteLiteral $account.achternaam
        $voornaam = ConvertTo-SqliteLiteral $account.voornaam
        $tussenvoegsel = ConvertTo-SqliteLiteral $account.tussenvoegsel

        $query = "UPDATE persons
                        SET email = '$($account.email)'
                        ,achternaam = '$achternaam'
                        ,voornaam = '$voornaam'
                        ,tussenvoegsel = '$tussenvoegsel'
                        ,gebruikersnaam = '$($account.gebruikersnaam)'
                        ,geslacht = '$($account.geslacht)'
                        ,createtime = datetime()
                        ,passief = $(if ([string]::IsNullOrWhiteSpace([string]$account.passief)) { 'NULL' } else { "'Ja'" })
                        WHERE gebruikersnaam = '$($actionContext.References.Account)'"

        if (-Not($actionContext.DryRun -eq $true)) {
            $null = Invoke-SqliteQuery -Query $query -DataSource $database
        }
        else {
            Write-Information "Would send: $query"
        }
        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "UpdateAccount"
                Message = "Account with username [$($account.gebruikersnaam)] updated"
                IsError = $false
            })
    }
    else {
        Write-Information "No account updates for SQLLite row with accountReference: [$($actionContext.References.Account)]"
    }

    ## Also fill roles table for each contract incondition

    ## Make sure old rows are deleted first, this could be nicer if we calculate differences in contracts but this works
    ## This should be done on aRef
    $query = "DELETE FROM roles WHERE gebruikersnaam = '$($actionContext.References.Account)'"
    if (-Not($actionContext.DryRun -eq $true)) {
        $null = Invoke-SqliteQuery -DataSource $database -Query $query
    }
    else {
        Write-Information  "Would execute: $query"
    }

    # Now calculate and set roles for contracts incondition
    $contracts = $personContext.Person.Contracts
    [array]$desiredContracts = $contracts | Where-Object { $_.Context.InConditions -eq $true -or $actionContext.DryRun -eq $true }

    if ($desiredContracts.length -lt 1) {
        throw 'No Contracts in scope [InConditions] found!'
    }
    elseif ($desiredContracts.length -ge 1) {
        foreach ($contract in $desiredContracts) {

            $departmentDisplayName = ConvertTo-SqliteLiteral $contract.department.displayname
            $titleName = ConvertTo-SqliteLiteral $contract.title.name
            $query = "INSERT OR REPLACE INTO Roles ('gebruikersnaam', 'ou', 'functie', 'oucode', 'functiecode', 'createtime') VALUES ('$($actionContext.References.Account)','$departmentDisplayName','$titleName','$($contract.department.externalid)','$($contract.title.externalId)',datetime());"
            if (-Not($actionContext.DryRun -eq $true)) {
                $null = Invoke-SqliteQuery -DataSource $database -Query $query
            }
            else {
                Write-Information "Would execute: $query"
            }
        }
        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "UpdatePermission"
                Message = "Roles for account with username [$($account.gebruikersnaam)] updated"
                IsError = $false
            })
    }
    else {
        Write-Information "No role updates for SQLLite row with accountReference: [$($actionContext.References.Account)]"
    }
    $outputContext.Data = $account
    $outputContext.PreviousData = $previousAccount
    $outputContext.Success = $true
}
catch {
    $ex = $PSItem
    $auditMessage = "Error adding data to SQL Lite DB. Error: $($ex.Exception.Message)"
    Write-Warning "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"

    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = "UpdateAccount"
            Message = $auditMessage
            IsError = $true
        })
    $outputContext.Success = $false
}