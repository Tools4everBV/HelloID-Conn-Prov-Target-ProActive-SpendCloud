#Initialize default properties
$p = $person | ConvertFrom-Json;
$config = $configuration | ConvertFrom-Json;

$database = $config.database
$verbose = $config.verbose

$success = $False;
$auditMessage = "Account for person " + $p.DisplayName + " not created succesfully"

#Change mapping here
$account = [PSCustomObject]@{
    email      = $p.Accounts.MicrosoftActiveDirectory.mail;
    voornamen  = $p.Name.NickName;
    achternaam = $p.Custom.TOPdeskSurName;
    adfs_login = $p.Accounts.MicrosoftActiveDirectory.SamAccountName;
    externalId = $p.ExternalId;
}

#correlation
$correlationField = 'externalId'
$correlationValue = $p.ExternalID

Try {    
    #Do not execute when running preview
    if (-Not($dryRun -eq $True)) {
        Import-Module PSSQLite       
        If (!(Test-Path $database)) {
            $query = "CREATE TABLE persons ($correlationField VARCHAR(100) PRIMARY KEY, email TEXT, achternaam TEXT, voornamen TEXT, adfs_login TEXT)"
            Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
            Write-Verbose -Verbose "Created new database $database with table name 'persons'"
            if ($verbose) {
                Invoke-SqliteQuery -DataSource $database -Query "PRAGMA table_info(persons)" -verbose:$verbose
            }
        }
        
        $query = "SELECT $correlationField FROM persons WHERE $correlationField = " + $correlationValue
        $correlationCheckResult = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
      
        #Check correlation before create
        if ($correlationCheckResult.externalId -eq $correlationValue) {
            $accountReference = ($correlationCheckResult.$correlationField)
            $success = $True
            $auditMessage = " with correlation for record with $($correlationField + " = " + $accountReference)"
        } else {
            $query = "INSERT OR REPLACE INTO persons ($correlationField, email, achternaam, voornamen, adfs_login) VALUES (@externalId,@email,@achternaam,@voornamen,@adfs_login);"
            $sqlParameters = $account.psobject.properties | ForEach-Object -begin {$h=@{}} -process {$h."$($_.Name)" = $_.Value} -end {$h}
            Invoke-SqliteQuery -DataSource $database -Query $query -SqlParameters $sqlParameters -Verbose:$verbose
            $accountReference = $p.ExternalId
            $success = $True
            $auditMessage = " succesfully"
        }
    }
}
catch {
    $auditMessage = " not created succesfully: General error";
    if ($verbose) {
        $_
    }
}

#build up result
$result = [PSCustomObject]@{ 
    Success          = $success;
    AccountReference = $accountReference;
    AuditDetails     = $auditMessage;
    Account          = $account;
    
    # Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{};
};


Write-Output $result | ConvertTo-Json -Depth 10;