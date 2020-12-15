#Initialize default properties
$aRef = $accountReference | ConvertFrom-Json;
$config = $configuration | ConvertFrom-Json;

$database = $config.database
$verbose = $config.verbose


#write-verbose -verbose $($accountReference.Identification)
$auditMessage = " not removed succesfully";

#Change mapping here
$account = [PSCustomObject]@{}

Try {
    If (Test-Path $database) {
		if(-Not($dryRun -eq $True)){  
			$query = "DELETE FROM persons WHERE externalId = '$aRef'"
            Invoke-SqliteQuery -Query $query -DataSource $database -Verbose:$verbose
            $success = $True;
            $auditMessage = " succesfully";
		}
    }
} catch{
	$auditMessage = " not removed succesfully: General error";
}

#build up result
$result = [PSCustomObject]@{ 
	Success= $success;
	AccountReference= $accountReference;
	AuditDetails=$auditMessage;
	Account = $account;
	
	# Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{};
};
Write-Output $result | ConvertTo-Json -Depth 10;