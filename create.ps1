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

    # Check if we should try to correlate the account
    if ($actionContext.CorrelationConfiguration.Enabled) {
        $correlationField = $actionContext.CorrelationConfiguration.accountField
        $correlationValue = $actionContext.CorrelationConfiguration.accountFieldValue

        if ($null -eq $correlationField) {
            Write-Warning "Correlation is enabled but not configured correctly."
        }

        # Write logic here that checks if the account can be correlated in the target system
        # Requesting authorization token

        try {
            $query = "SELECT $correlationField,achternaam FROM persons WHERE $correlationField = '$correlationValue'"
            $correlationCheckResult = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose

            if ($correlationCheckResult.externalId -eq $correlationValue) {
                $correlatedAccount = $true
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

        if ($null -ne $correlatedAccount) {        
            Write-Verbose "correlation found in SQL Lite DB for [$($person.DisplayName) ($correlationValue)] "   

            $outputContext.AccountReference = ($correlationCheckResult.$correlationField)      

            $outputContext.AuditLogs.Add([PSCustomObject]@{
                    Action  = "CorrelateAccount" # Optionally specify a different action for this audit log
                    Message = "Correlated account with username $correlationValue"
                    IsError = $false
                })
         
            if ($actionContext.Configuration.UpdatePersonOnCorrelate -eq 'True') {     
                $outputContext.AccountCorrelated = $True        
            }
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
                    Message = "Failed to create account with username $($account.Gebruikersnaam), due to incomplete account. $message"
                    IsError = $true
                })     
        }
        else {        
            try {
                $query = "INSERT OR REPLACE INTO persons ($correlationField, email, achternaam, voornaam, tussenvoegsel, gebruikersnaam,geslacht,createtime) VALUES (@externalId,@email,@achternaam,@voornaam,@tussenvoegsel,@gebruikersnaam,@geslacht,datetime());"
                $sqlParameters = $account.psobject.properties | ForEach-Object -begin { $h = @{} } -process { $h."$($_.Name)" = $_.Value } -end { $h }

                if (-Not($actionContext.DryRun -eq $true)) {          
                    $null = Invoke-SqliteQuery -DataSource $database -Query $query -SqlParameters $sqlParameters -Verbose:$verbose
                    
                    $outputContext.AuditLogs.Add([PSCustomObject]@{
                        Action  = "CreateAccount" # Optionally specify a different action for this audit log
                        Message = "Created account with username $($account.Gebruikersnaam)"
                        IsError = $false
                    })

                }
                    
                $outputContext.AccountReference = $account.externalId


                    
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
                throw "Error adding data to SQL Lite DB"
                    
            }
                   
            if ($actionContext.DryRun -eq $true) {
            
                Write-Warning "Row with username [$($account.Gebruikersnaam)] would be added to the DB."
                $outputContext.AuditLogs.Add([PSCustomObject]@{
                        Action  = "CreateAccount" # Optionally specify a different action for this audit log
                        Message = "Row with username [$($account.Gebruikersnaam)] would be added to the DB."
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
    throw "Error adding data to SQL Lite DB"
}

finally {
    # Check if auditLogs contains errors, if no errors are found, set success to true
    if (-NOT($outputContext.AuditLogs.IsError -contains $true)) {
        $outputContext.Success = $true
    }

    $outputContext.Data = $account 
}