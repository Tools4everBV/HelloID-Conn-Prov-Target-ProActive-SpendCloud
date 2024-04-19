$type = "csv" # type can be database and csv
$system = "ProActive" # name of the HelloID provisioning SQLite connector
$verbose = $False #Turn verbosity on or off
$database = "C:\HelloID\Spendcloud\Spendcloud.db" #The database location
$destinationFile = "C:\HelloID\Spendcloud\ProActive.csv"
$destinationFileRoles = "C:\HelloID\Spendcloud\ProActiveRoles.csv"

Write-Information "Starting export" 

If (Test-Path $database) {
    Import-Module PSSQLite 
    
    $query = "SELECT voornaam,tussenvoegsel,achternaam,geslacht,email,gebruikersnaam FROM persons"
    $result = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
    if ($result.Count -eq 0) {
       $auditMessage = "Failed. Export with query '$query' resulted in 0 records" 
    } else  {   
       $result |Export-Csv -Path $destinationFile -NoTypeInformation -Delimiter ";" -Encoding "utf8"  -Verbose:$verbose
       $auditMessage = "exported $($result.Count) records to $destinationFile"
    }
    
    $query = 'SELECT "ou" as "Organisatorische Eenheid", "gebruikersnaam" as "Gebruikersnaam", "functiecode" as "Functieprofiel Code" FROM roles'
    $result = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
    if ($result.Count -eq 0) {
       $auditMessage = "Failed. Export with query '$query' resulted in 0 records" 
    } else  {   
       $result |Export-Csv -Path $destinationFileRoles -NoTypeInformation -Delimiter "," -Encoding "utf8"  -Verbose:$verbose
       $auditMessage = "exported $($result.Count) records to $destinationFile"
    }
    
} else {
    $auditMessage = "Failed to locate the database '$database'"
    $event = "Failed"
}

