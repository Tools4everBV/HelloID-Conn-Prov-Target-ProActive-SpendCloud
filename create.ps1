#############################################
# HelloID-Conn-Prov-Target-SpendCloud-Create
#############################################

# Initialize default values
$config = $actionContext.Configuration
$outputContext.AccountReference = "DRYRUN"
$database = $config.database

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
    $person = $personContext.Person

    # Make sure module is imported
    Import-Module PSSQLite

    # Check if we should try to correlate the account
    if ($actionContext.CorrelationConfiguration.Enabled) {
        $correlationField = $actionContext.CorrelationConfiguration.accountField
        $correlationValue = $actionContext.CorrelationConfiguration.accountFieldValue

        if ([string]::IsNullOrEmpty($($correlationValue))) {
            throw 'Correlation is enabled but [accountFieldValue] is empty. Please make sure it is correctly configured'
        }

        # Requesting authorization token
        $query = "SELECT $correlationField,achternaam,gebruikersnaam FROM persons WHERE $correlationField = '$correlationValue'"
        $correlationCheckResult = Invoke-SqliteQuery -Query $query -DataSource $database
        if ($correlationCheckResult.externalId -eq $correlationValue) {
            $correlatedAccount = $true
        }
    }

    if ($null -ne $correlatedAccount) {
        Write-Information "correlation found in SQL Lite DB for person [$($person.DisplayName)] with correlation value [$correlationValue]"
        $outputContext.AccountReference = ($correlationCheckResult.gebruikersnaam)

        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "CorrelateAccount"
                Message = "Correlated account with username [$($correlationCheckResult.gebruikersnaam)] using correlation field [$correlationField] and value [$correlationValue]"
                IsError = $false
            })
        $outputContext.AccountCorrelated = $true
    }
    else {
        #$sqlParameters = $account.psobject.properties | ForEach-Object -begin { $h = @{} } -process { $h."$($_.Name)" = $_.Value } -end { $h }
        #$query = "INSERT OR REPLACE INTO persons (externalId, email, achternaam, voornaam, tussenvoegsel, gebruikersnaam,geslacht,createtime) VALUES (@externalId,@email,@achternaam,@voornaam,@tussenvoegsel,@gebruikersnaam,@geslacht,datetime());"
        $achternaam = ConvertTo-SqliteLiteral $account.achternaam
        $voornaam = ConvertTo-SqliteLiteral $account.voornaam
        $tussenvoegsel = ConvertTo-SqliteLiteral $account.tussenvoegsel

        $query = "INSERT OR REPLACE INTO persons (externalId, email, achternaam, voornaam, tussenvoegsel, gebruikersnaam,geslacht,createtime,passief) VALUES ('$($account.externalId)','$($account.email)','$achternaam','$voornaam','$tussenvoegsel','$($account.gebruikersnaam)','$($account.geslacht)',datetime(),NULL);"

        if (-Not($actionContext.DryRun -eq $true)) {
            $null = Invoke-SqliteQuery -DataSource $database -Query $query
        }

        $outputContext.AccountReference = $account.gebruikersnaam
        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "CreateAccount"
                Message = "Created account with username [$($account.gebruikersnaam)]"
                IsError = $false
            })

        ## Also fill roles table for each contract incondition
        $contracts = $personContext.Person.Contracts

        [array]$desiredContracts = $contracts | Where-Object { $_.Context.InConditions -eq $true -or $actionContext.DryRun -eq $true }

        if ($desiredContracts.length -lt 1) {
            # no contracts in scope found
            throw 'No Contracts in scope [InConditions] found!'
        }
        elseif ($desiredContracts.length -ge 1) {
            # one or more contracts found
            foreach ($contract in $desiredContracts) {
                $departmentDisplayName = ConvertTo-SqliteLiteral $contract.department.displayname
                $titleName = ConvertTo-SqliteLiteral $contract.title.name
                $query = "INSERT OR REPLACE INTO Roles ('gebruikersnaam', 'ou', 'functie', 'oucode', 'functiecode', 'createtime') VALUES ('$($account.gebruikersnaam)','$departmentDisplayName','$titleName','$($contract.department.externalid)','$($contract.title.externalId)',datetime());"
                
                if (-Not($actionContext.DryRun -eq $true)) {
                    $null = Invoke-SqliteQuery -DataSource $database -Query $query
                }
                else {
                    Write-Information "Would execute: $query"
                }
            }
        }

        if ($actionContext.DryRun -eq $true) {
            Write-Warning "Row with username [$($account.gebruikersnaam)] would be added to the DB. Query: $query"
            $outputContext.AuditLogs.Add([PSCustomObject]@{
                    Action  = "CreateAccount"
                    Message = "Row with username [$($account.gebruikersnaam)] would be added to the DB."
                    IsError = $false
                })
        }
    }
    $outputContext.Data = $account
    $outputContext.Success = $true
}
catch {
    $ex = $PSItem
    $auditMessage = "Error adding data to SQL Lite DB. Error: $($ex.Exception.Message)"
    Write-Warning "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"

    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = "CreateAccount"
            Message = $auditMessage
            IsError = $false
        })
    $outputContext.Success = $false
}