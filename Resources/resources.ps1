#####################################################
# HelloID-Conn-Prov-Target-SpendCloudV2-Resource
#####################################################

# Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region functions
$database = $actionContext.Configuration.database
$destinationFile = $actionContext.Configuration.destinationFile
$destinationFileRoles = $actionContext.Configuration.destinationFileRoles

try {
    If (Test-Path $database) {
        Import-Module PSSQLite

        $query = "SELECT voornaam,tussenvoegsel,achternaam,geslacht,email,gebruikersnaam FROM persons"
        $result = Invoke-SqliteQuery -Query $query -DataSource $database
        if ($result.Count -eq 0) {
            throw "Failed. Export to [$destinationFile] with query '$query' resulted in 0 records" 
        }
        else {
            $result | Export-Csv -Path $destinationFile -NoTypeInformation -Delimiter ";" -Encoding "utf8"
            $outputContext.AuditLogs.Add([PSCustomObject]@{
                Action  = "CreateResource"
                Message = "Exported $($result.Count) records to $destinationFile"
                IsError = $true
            })
        }

        if ($destinationFileRoles) {
            $query = 'SELECT "ou" as "Organisatorische Eenheid", "gebruikersnaam" as "Gebruikersnaam", "functiecode" as "Functieprofiel Code" FROM roles'
            $result = Invoke-SqliteQuery -Query $query -DataSource $database
            if ($result.Count -eq 0) {
                throw "Failed. Export to [$destinationFileRoles] with query [$query] resulted in 0 records"
            }
            else {   
                $result | Export-Csv -Path $destinationFileRoles -NoTypeInformation -Delimiter "," -Encoding "utf8"
                $outputContext.AuditLogs.Add([PSCustomObject]@{
                    Action  = "CreateResource"
                    Message = "Exported $($result.Count) records to $destinationFile"
                    IsError = $true
                })
            }
        }
        $outputContext.Success = $true
    }
    else {
        throw "Database file [$database] not found"
    }
}
catch {
    $ex = $PSItem
    $auditMessage = "Error exporting databasefile. Error: $($ex.Exception.Message)"
    Write-Warning "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"

    $outputContext.AuditLogs.Add([PSCustomObject]@{
        Action  = "CreateResource"
        Message = $auditMessage
        IsError = $true
    })
    $outputContext.Success = $false
}