#####################################################
# HelloID-Conn-Prov-Target-SpendCloudV2-Resource
#
# Version: 2.0.0 | new-powershell-connector
#####################################################

# Set to true at start, because only when an error occurs it is set to false
$outputContext.Success = $true

# Set debug logging
switch ($($actionContext.Configuration.isDebug)) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}

# Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region functions
$type = "csv" # type can be database and csv
$system = "ProActive" # name of the HelloID provisioning SQLite connector
$database = $actionContext.Configuration.database #The database location
$destinationFile = $actionContext.Configuration.destinationFile
$destinationFileRoles = $actionContext.Configuration.destinationFileRoles

try {
    If (Test-Path $database) {
        Import-Module PSSQLite 
        
        $query = "SELECT voornaam,tussenvoegsel,achternaam,geslacht,email,gebruikersnaam FROM persons"
        $result = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
        if ($result.Count -eq 0) {
            $auditMessage = "Failed. Export with query '$query' resulted in 0 records" 
        }
        else {   
            $result | Export-Csv -Path $destinationFile -NoTypeInformation -Delimiter ";" -Encoding "utf8"  -Verbose:$verbose
            $auditMessage = "exported $($result.Count) records to $destinationFile"
        }
        
        if ($destinationFileRoles) {
            $query = 'SELECT "ou" as "Organisatorische Eenheid", "gebruikersnaam" as "Gebruikersnaam", "functiecode" as "Functieprofiel Code" FROM roles'
            $result = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
            if ($result.Count -eq 0) {
                $auditMessage = "Failed. Export with query '$query' resulted in 0 records" 
            }
            else {   
                $result | Export-Csv -Path $destinationFileRoles -NoTypeInformation -Delimiter "," -Encoding "utf8"  -Verbose:$verbose
                $auditMessage = "exported $($result.Count) records to $destinationFile"
            }
        }
        
    }
    else {
        throw "Databasefile not found"
    }

}
catch {
    write-error "$($_)"
    $ex = $PSItem
          
    $auditMessage = "Error exporting databasefile. Error: $($ex.Exception.Message)"
    Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"

    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = "CreateAccount" # Optionally specify a different action for this audit log
            Message = $auditMessage
            IsError = $true
        })
    throw "Error exporting databasefile"
}
finally {
    # Check if auditLogs contains errors, if errors are found, set success to false
    if ($outputContext.AuditLogs.IsError -contains $true) {
        $outputContext.Success = $false
    }
}