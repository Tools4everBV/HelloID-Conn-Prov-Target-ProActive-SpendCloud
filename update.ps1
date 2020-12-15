#Initialize default properties
$p = $person | ConvertFrom-Json;
$aRef = $accountReference | ConvertFrom-Json
$config = $configuration | ConvertFrom-Json

$database = $config.database
$verbose = $config.verbose

$success = $False
$auditMessage = "Account for person " + $p.DisplayName + " not updated succesfully"

#Change mapping here
$account = [PSCustomObject]@{
    email      = $p.Accounts.MicrosoftActiveDirectory.mail;
    voornamen  = $p.Name.NickName;
    achternaam = $p.Custom.TOPdeskSurName;
    adfs_login = $p.Accounts.MicrosoftActiveDirectory.SamAccountName;
    externalId = $p.ExternalId;
}

Try {
	if(-Not($dryRun -eq $True)){
        If (Test-Path $database) {
            Import-Module PSSQLite
            $query = "UPDATE persons SET email = '$($account.email)', achternaam = '$($account.achternaam)', voornamen = '$($account.voornamen)', adfs_login = '$($account.adfs_login)' WHERE externalId = '$($aRef)'"
            $null = Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose

            $success = $True
            $auditMessage = " succesfully"
		}
    }
} catch{
	$auditMessage = " not removed succesfully: General error"
    Write-Verbose -Verbose "$_"
}

#build up result
$result = [PSCustomObject]@{ 
	Success= $success;
	AccountReference= $accountReference;
	AuditDetails=$auditMessage;
	Account = $account;
	
	# Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{};
}
Write-Output $result | ConvertTo-Json -Depth 10
