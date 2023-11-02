#####################################################
# HelloID-Conn-Prov-Target-ProActive-SpendCloud-delete
#
# Version: 1.1.0
#####################################################

#Initialize default properties
$aRef = $accountReference | ConvertFrom-Json;
$config = $configuration | ConvertFrom-Json;

$database = $config.database
$verbose = $config.verbose
$auditLogs = [Collections.Generic.List[PSCustomObject]]::new()

Try {
    If (Test-Path $database) {
        Import-Module PSSQLite     
        $query = "DELETE FROM persons WHERE externalId = '$aRef'"
        if (-Not($dryRun -eq $True)) {
            $null = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose  
        }
        $success = $true
        $auditLogs.Add([PSCustomObject]@{
                Action  = "DeleteAccount"
                Message = "Account deleted for $($account.email) ($($aref))"
                IsError = $false
            }) 
    }
}
catch {
    $success = $false
    $auditLogs.Add([PSCustomObject]@{
            Action  = "DeleteAccount"
            Message = "Failed to delete account - $($_)"
            IsError = $true
        })
}

#build up result
$result = [PSCustomObject]@{ 
    Success          = $success;
    AccountReference = $aRef;
    auditLogs        = $auditLogs;
    Account          = $account;
    
};
Write-Output $result | ConvertTo-Json -Depth 10;