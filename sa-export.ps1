
$type = "csv" # type can be database and csv
$system = "ProActive" # name of the HelloID provisioning SQLite connector
$verbose = $False #Turn verbosity on or off
$database = "C:\HelloID - Ondersteunend\ProActive SQLite database\HelloID-ProActive.db" #The database location
$destinationFile = "C:\HelloID - Ondersteunend\ProActive export\ProActive.csv"
$event = "Failed"

Hid-Write-Status -Message "Starting '$type' export for provisioning connector '$system'" -Event Information

If (Test-Path $database) {
    Import-Module PSSQLite 
    $fileInfo = Get-ItemProperty -Path $database
    if ($fileinfo.LastWriteTime -lt (Get-Date).AddMinutes(-30)) {
        $query = "SELECT email,achternaam,voornamen,adfs_login FROM persons"
        $result = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
        if ($result.Count -eq 0) {
            $auditMessage = "Failed. Export with query '$query' resulted in 0 records" 
        } else  {   
            $result |Export-Csv -Path $destinationFile -NoTypeInformation -Delimiter ";" -Encoding "utf8"  -Verbose:$verbose
            $auditMessage = "exported $($result.Count) records to $destinationFile"
            $event = "Success"
        }
    } else {
        $auditMessage = "Database '$database' has been updated in the last 30 minutes, please change the Service Automation Task schedule"
    }
} else {
    $auditMessage = "Failed to locate the database '$database'"
    $event = "Failed"
}
Hid-Write-Status -Message "Finished '$type' export for provisioning connector '$system': $auditMessage" -Event $event
HID-Write-Summary -Message "Finished '$type' export for provisioning connector '$system': $auditMessage" -Event $event
