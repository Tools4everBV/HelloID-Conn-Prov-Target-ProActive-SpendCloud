########################################
# HelloID-Conn-Prov-Target-SpendCloudV2-Update
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

    Write-Verbose "Verifying if DB row exists"
    try {
        ## Mooier zou zijn met aRef? 
        $correlationField = $actionContext.CorrelationConfiguration.accountField
        $correlationValue = $actionContext.CorrelationConfiguration.accountFieldValue

        $query = "SELECT * FROM persons WHERE $correlationField = '$correlationValue'"
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
        gender         = $currentAccount.gender
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
    $oldProperties = $changedProperties.Where( { $_.SideIndicator -eq '<=' })
    $newProperties = $changedProperties.Where( { $_.SideIndicator -eq '=>' })

    if (($newProperties | Measure-Object).Count -ge 1) {

        If (Test-Path $database) {
            Import-Module PSSQLite     
            $query = "UPDATE persons 
                        SET email = @email
                        ,achternaam = @achternaam
                        ,voornaam = @voornaam
                        ,tussenvoegsel = @tussenvoegsel
                        ,gebruikersnaam = @gebruikersnaam
                        ,geslacht = @geslacht
                        ,createtime = datetime()
                        WHERE externalId = @externalId"
    
            $sqlParameters = $account.psobject.properties | ForEach-Object -begin { $h = @{} } -process { $h."$($_.Name)" = $_.Value } -end { $h }
    
            if (-Not($actionContext.DryRun -eq $true)) { 
                $null = Invoke-SqliteQuery -Query $query -DataSource $database -SqlParameters $sqlParameters -Verbose:$verbose
            }
            else {
                Write-warning "Would send: $query" 
            }
              
            
            $outputContext.AuditLogs.Add([PSCustomObject]@{
                    Action  = "UpdateAccount" # Optionally specify a different action for this audit log
                    Message = "Account with username $($account.userName) updated"
                    IsError = $false
                })
        }
        
    }
    else {
        Write-Verbose "No Updates for SQLLite row with accountReference: [$($actionContext.References.Account)]"
        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "UpdateAccount" # Optionally specify a different action for this audit log
                Message = "Account with username $($account.userName) has no updates"
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