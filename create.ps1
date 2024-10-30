########################################
# HelloID-Conn-Prov-Target-SpendCloudV2-Create
#
# Version: 2.0.0
########################################

# Initialize default values
$config = $actionContext.Configuration
$outputContext.success = $false
$outputContext.AccountReference = "DRYRUN"

$database = $config.database
$verbose = $config.verbose

#$actionContext.DryRun = $false

# Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# Set debug logging
switch ($($actionContext.Configuration.isDebug)) {
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

    # Check if we should try to correlate the account
    if ($actionContext.CorrelationConfiguration.Enabled) {
        $correlationField = $actionContext.CorrelationConfiguration.accountField
        $correlationValue = $actionContext.CorrelationConfiguration.accountFieldValue

        if ([string]::IsNullOrEmpty($($correlationValue))) {
            throw 'Correlation is enabled but [accountFieldValue] is empty. Please make sure it is correctly mapped'
        }

        # Write logic here that checks if the account can be correlated in the target system
        # Requesting authorization token

        try {
            $query = "SELECT $correlationField,achternaam,gebruikersnaam FROM persons WHERE $correlationField = '$correlationValue'"
            $correlationCheckResult = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
            if ($correlationCheckResult.externalId -eq $correlationValue) {
                $correlatedAccount = $true
            }
        }
        catch {
            write-error "$($_)"
            $ex = $PSItem

            Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
            throw "Error querying data from SQL Lite DB"
        }

        if ($null -ne $correlatedAccount) {        
            Write-Verbose "correlation found in SQL Lite DB for [$($person.DisplayName) ($correlationValue)] "   
            $outputContext.AccountReference = ($correlationCheckResult.gebruikersnaam)      

            $outputContext.AuditLogs.Add([PSCustomObject]@{
                    Action  = "CorrelateAccount" # Optionally specify a different action for this audit log
                    Message = "Correlated account with username $correlationValue"
                    IsError = $false
                })
         
            $outputContext.AccountCorrelated = $True
            
            #if ($actionContext.Configuration.UpdatePersonOnCorrelate -eq 'True') {     
            #    $outputContext.AccountCorrelated = $True        
            #}
        }
    }


    if (!$outputContext.AccountCorrelated -and $null -eq $correlatedAccount) {
        # Create account object from mapped data and set the correct account reference
        $incompleteAccount = $false

        #Incomplete account settings
        if ([string]::IsNullOrEmpty($account.externalId)) {
            $incompleteAccount = $true
            $message = "Person does not has a employeenumber"
            Write-Warning "Person does not has a employeenumber"
        }

        if ($incompleteAccount) {
            $outputContext.AuditLogs.Add([PSCustomObject]@{
                    Action  = "CreateAccount" # Optionally specify a different action for this audit log
                    Message = "Failed to create account with username $($account.UserName), due to incomplete account. $message"
                    IsError = $true
                })     
        }
        else {        
            try {
                #$query = "INSERT OR REPLACE INTO persons (externalId, email, achternaam, voornaam, tussenvoegsel, gebruikersnaam,geslacht,createtime) VALUES (@externalId,@email,@achternaam,@voornaam,@tussenvoegsel,@gebruikersnaam,@geslacht,datetime());"
                $query = "INSERT OR REPLACE INTO persons (externalId, email, achternaam, voornaam, tussenvoegsel, gebruikersnaam,geslacht,createtime) VALUES ('$($account.externalId)','$($account.email)','$($account.achternaam)','$($account.voornaam)','$($account.tussenvoegsel)','$($account.gebruikersnaam)','$($account.gender)',datetime());"
                
                #$sqlParameters = $account.psobject.properties | ForEach-Object -begin { $h = @{} } -process { $h."$($_.Name)" = $_.Value } -end { $h }

                if (-Not($actionContext.DryRun -eq $true)) {          
                    $null = Invoke-SqliteQuery -DataSource $database -Query $query -Verbose:$verbose
                }
                    
                $outputContext.AccountReference = $account.gebruikersnaam

                $outputContext.AuditLogs.Add([PSCustomObject]@{
                        Action  = "CreateAccount" # Optionally specify a different action for this audit log
                        Message = "Created account with username $($account.UserName)"
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
                    foreach ($contract in $desiredContracts){
                        
                        $query = "INSERT OR REPLACE INTO Roles ('gebruikersnaam', 'ou', 'functie', 'oucode', 'functiecode', 'createtime') VALUES ('$($account.gebruikersnaam)','$($contract.department.displayname)','$($contract.title.name)','$($contract.department.externalid)','$($contract.title.code)',datetime());"
                        if (-Not($actionContext.DryRun -eq $true)) {          
                            $null = Invoke-SqliteQuery -DataSource $database -Query $query -Verbose:$verbose
                        } else {
                            Write-verbose -verbose "Would execute: $query"
                        }
                    }
                }                    
            }
            catch {             
                write-error "$($_)"
                $ex = $PSItem
                          
                Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
                throw "Error adding data to SQL Lite DB"
                    
            }
                   
            if ($actionContext.DryRun -eq $true) {
            
                Write-Warning "Row with username [$($account.gebruikersnaam)] would be added to the DB. Query: $query"
                $outputContext.AuditLogs.Add([PSCustomObject]@{
                        Action  = "CreateAccount" # Optionally specify a different action for this audit log
                        Message = "Row with username [$($account.gebruikersnaam)] would be added to the DB."
                        IsError = $false
                    })
            }

        }
    }  
}
catch {
    write-error "$($_)"
    $ex = $PSItem
          
    $auditMessage = "Error adding data to SQL Lite DB. Error: $($ex.Exception.Message)"
    Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"

    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = "CreateAccount" # Optionally specify a different action for this audit log
            Message = $auditMessage
            IsError = $false
        })
    
}

finally {
    # Check if auditLogs contains errors, if no errors are found, set success to true
    if (-NOT($outputContext.AuditLogs.IsError -contains $true)) {
        $outputContext.Success = $true
    }

    $outputContext.Data = $account 
}