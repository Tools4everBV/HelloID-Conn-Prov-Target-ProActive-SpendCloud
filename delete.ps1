########################################
# HelloID-Conn-Prov-Target-SpendCloudV2-Delete
#
# Version: 2.0.0
########################################

# Initialize default values
$config = $actionContext.Configuration
$p = $personContext.Person
$outputContext.Success = $false

$database = $config.database
$verbose = $config.verbose

# Set debug logging
switch ($verbose) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}

#region functions
try {
    If (Test-Path $database) {
        $account = $actionContext.Data;

        <#
        # Make sure module is imported
        $moduleName = "PSSQLite"

        # If module is imported say that and do nothing
        if (Get-Module -Verbose:$false | Where-Object { $_.Name -eq $ModuleName }) {
                Write-Verbose "Module [$ModuleName] is already imported."
            }
        else {
                # If module is not imported, but available on disk then import
                if (Get-Module -ListAvailable -Verbose:$false | Where-Object { $_.Name -eq $ModuleName }) {
                    $module = Import-Module $ModuleName -Verbose:$false
                    Write-Verbose "Imported module [$ModuleName]"
                }
                else {
                    # If the module is not imported, not available and not in the online gallery then abort
                    throw "Module [$ModuleName] is not available. Please install the module using: Install-Module -Name [$ModuleName] -Force"
                }
        }  
        #>

        $query = "DELETE FROM persons WHERE gebruikersnaam = '$($outputContext.AccountReference)'"
            
        if (-Not($actionContext.DryRun -eq $true)) { 
            $null = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose  
        }
        else {
            Write-warning "Would send: $query" 
        }

        ## Also delete rows for roles
        $query = "DELETE FROM roles WHERE gebruikersnaam = '$($outputContext.AccountReference)'"
            
        if (-Not($actionContext.DryRun -eq $true)) { 
            $null = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose  
        }
        else {
            Write-warning "Would send: $query" 
        }
                      
                    
        $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "DeleteAccount" # Optionally specify a different action for this audit log
                Message = "Delete account [$($p.DisplayName)] with reference [$($actionContext.References.Account)] was successful."
                IsError = $false
            })
    }
}
catch {
    write-error "$($_)"
    $ex = $PSItem
          
    $auditMessage = "Error removing data from SQL Lite DB. Error: $($ex.Exception.Message)"
    Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"

    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = "DeleteAccount" # Optionally specify a different action for this audit log
            Message = $auditMessage
            IsError = $false
        })
    throw "Error removing data from SQL Lite DB"
}
finally {
    # Check if auditLogs contains errors, if no errors are found, set success to true
    if (-NOT($outputContext.AuditLogs.IsError -contains $true)) {
        $outputContext.Success = $true
    }
    # Retrieve account information for notifications
    #$outputContext.PreviousData.ExternalId = $personContext.References.Account
}