########################################
# HelloID-Conn-Prov-Target-SpendCloudV2-Update
#
# Version: 2.0.0
########################################

# Initialize default values
$outputContext.success = $false
$database = $actionContext.Configuration.database
$verbose = $actionContext.Configuration.verbose

# Set debug logging
switch ($verbose) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}

#region functions

#endregion functions
try {
    # Create account object from mapped data and set the correct account reference
    $account = $actionContext.Data;
    $person = $personContext.Person;

    # Make sure module is imported
    Import-Module PSSQLite 

    Write-Verbose "Verifying if DB row exists"
    try {
        $query = "SELECT * FROM persons WHERE gebruikersnaam = '$($actionContext.References.Account)'"
        $correlationCheckResult = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose

        if ($correlationCheckResult.externalId -eq $correlationValue) {
            $currentAccount = $correlationCheckResult
        }

    }
    catch {
        write-error "$($_)"
        $ex = $PSItem
        
        $auditMessage = "Error querying data from SQL Lite DB. Error: $($ex.Exception.Message)"
        Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
        
        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "CreateAccount" # Optionally specify a different action for this audit log
                Message = $auditMessage
                IsError = $false
            })
        throw "Error querying data from SQL Lite DB"
    }

    $previousAccount = [PSCustomObject]@{
        achternaam     = $currentAccount.achternaam
        tussenvoegsel  = $currentAccount.tussenvoegsel
        voornaam       = $currentAccount.voornaam
        gebruikersnaam = $currentAccount.gebruikersnaam
        geslacht       = $currentAccount.gender
        externalId     = $currentAccount.externalId
        email          = $currentAccount.email
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

        
        $query = "UPDATE persons 
                        SET email = '$($account.email)'
                        ,achternaam = '$($account.achternaam)'
                        ,voornaam = '$($account.voornaam)'
                        ,tussenvoegsel = '$($account.tussenvoegesel)'
                        ,gebruikersnaam = '$($account.gebruikersnaam)'
                        ,geslacht = '$($account.gender)'
                        ,createtime = datetime()
                        WHERE gebruikersnaam = '$($actionContext.References.Account)'"
    
        if (-Not($actionContext.DryRun -eq $true)) { 
            $null = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
        }
        else {
            Write-warning "Would send: $query" 
        }
              
        ## Also fill roles table for each contract incondition

        ## Make sure old rows are deleted first, this could be nicer if we calculate differences in contracts but this works
        ## This should be done on aRef

        $query = "DELETE FROM roles WHERE gebruikersnaam = '$($actionContext.References.Account)'"
        if (-Not($actionContext.DryRun -eq $true)) {          
            $null = Invoke-SqliteQuery -DataSource $database -Query $query -Verbose:$verbose
        }
        else {
            Write-verbose -verbose "Would execute: $query"
        }

        # Now calculate and set roles for contracts incondition
        $contracts = $personContext.Person.Contracts

        [array]$desiredContracts = $contracts | Where-Object { $_.Context.InConditions -eq $true -or $actionContext.DryRun -eq $true }

        if ($desiredContracts.length -lt 1) {
            # no contracts in scope found
            throw 'No Contracts in scope [InConditions] found!'
        }
        elseif ($desiredContracts.length -ge 1) {
            # one or more contracts found
            foreach ($contract in $desiredContracts) {
                        
                $query = "INSERT OR REPLACE INTO Roles ('gebruikersnaam', 'ou', 'functie', 'oucode', 'functiecode', 'createtime') VALUES ('$($actionContext.References.Account)','$($contract.department.displayname)','$($contract.title.name)','$($contract.department.externalid)','$($contract.title.code)',datetime());"
                if (-Not($actionContext.DryRun -eq $true)) {          
                    $null = Invoke-SqliteQuery -DataSource $database -Query $query -Verbose:$verbose
                }
                else {
                    Write-verbose -verbose "Would execute: $query"
                }
            }
        }                    


        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "UpdateAccount" # Optionally specify a different action for this audit log
                Message = "Account with username $($account.gebruikersnaam) updated"
                IsError = $false
            })
        
        
    }
    else {
        Write-Verbose "No Updates for SQLLite row with accountReference: [$($actionContext.References.Account)]"
        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "UpdateAccount" # Optionally specify a different action for this audit log
                Message = "Account with username $($account.gebruikersnaam) has no updates"
                IsError = $false
            })
    }  
}
catch {
    write-error "$($_)"
    $ex = $PSItem
          
    $auditMessage = "Error adding data to SQL Lite DB. Error: $($ex.Exception.Message)"
    Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"

    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = "UpdateAccount" # Optionally specify a different action for this audit log
            Message = $auditMessage
            IsError = $false
        })
    throw "Error adding data to SQL Lite DB"
}

finally {
    # Check if auditLogs contains errors, if no errors are found, set success to true
    if (-NOT($outputContext.AuditLogs.IsError -contains $true)) {
        $outputContext.Success = $true
    }

    $outputContext.Data = $account 
    $outputContext.PreviousData = $previousAccount
}