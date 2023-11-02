#####################################################
# HelloID-Conn-Prov-Target-ProActive-SpendCloud-update
# Version: 1.1.0
#####################################################

#Initialize default properties
$p = $person | ConvertFrom-Json;
$aRef = $accountReference | ConvertFrom-Json
$config = $configuration | ConvertFrom-Json;

$database = $config.database
$verbose = $config.verbose
$auditLogs = [Collections.Generic.List[PSCustomObject]]::new()

function GenerateMiddleName {
    [cmdletbinding()]
    Param (
        [object]$person
    )
    try {
        $FamilyNamePrefix = $person.Name.FamilyNamePrefix 
        $PartnerNamePrefix = $person.Name.FamilyNamePartnerPrefix
        $convention = $person.Name.Convention

        $middlename = ""
        switch ($convention) {
            "B" {
                $middlename = $FamilyNamePrefix;
            }
            "P" {
                $middlename = $PartnerNamePrefix;                 
            }
            "BP" {
                $middlename = $FamilyNamePrefix;
            }
            "PB" {
                $middlename = $PartnerNamePrefix;   
            }
            Default {
                $middlename = $FamilyNamePrefix;
            }
        }

        return $middlename
    }
    catch {
        throw("An error was found in the name convention algorithm: $($_.Exception.Message): $($_.ScriptStackTrace)")
    
    }

}
function GenerateLastName {
    [cmdletbinding()]
    Param (
        [object]$person
    )

    try {
        $suffix = "";
        $givenname = if ([string]::IsNullOrEmpty($person.Name.Nickname)) { $person.Name.Initials.Substring(0, 1) }else { $person.Name.Nickname }
        $FamilyNamePrefix = $person.Name.FamilyNamePrefix
        $FamilyName = $person.Name.FamilyName           
        $PartnerNamePrefix = $person.Name.FamilyNamePartnerPrefix
        $PartnerName = $person.Name.FamilyNamePartner 
        $convention = $person.Name.Convention

        $LastName = ""

        switch ($convention) {
            "B" {
                #  $LastName += if (-NOT([string]::IsNullOrEmpty($FamilyNamePrefix))) { $FamilyNamePrefix + " " }
                $LastName += $FamilyName  
            }
            "P" {
                #   $LastName += if (-NOT([string]::IsNullOrEmpty($FamilyNamePrefix))) { $FamilyNamePrefix + " " }
                $LastName += $PartnerName                    
            }
            "BP" {
                #   $LastName += if (-NOT([string]::IsNullOrEmpty($FamilyNamePrefix))) { $FamilyNamePrefix + " " }
                $LastName += $FamilyName + " - "
                $LastName += if (-NOT([string]::IsNullOrEmpty($PartnerNamePrefix))) { $PartnerNamePrefix + " " }
                $LastName += $PartnerName
            }
            "PB" {
                #   $LastName += if (-NOT([string]::IsNullOrEmpty($PartnerNamePrefix))) { $PartnerNamePrefix + " " }
                $LastName += $PartnerName + " - "
                $LastName += if (-NOT([string]::IsNullOrEmpty($FamilyNamePrefix))) { $FamilyNamePrefix + " " }
                $LastName += $FamilyName
            }
            Default {
                #   $LastName += if (-NOT([string]::IsNullOrEmpty($FamilyNamePrefix))) { $FamilyNamePrefix + " " }
                $LastName += $FamilyName

            }
        }
            
        return $LastName
            
    }
    catch {
        throw("An error was found in the name convention algorithm: $($_.Exception.Message): $($_.ScriptStackTrace)")
    } 
}


switch ($p.details.gender) {
    "Female" 
    { $gender = "V" }
    "Male" 
    { $gender = "M" }
    Default 
    { $gender = "O" }
}

#Change mapping here
$account = [PSCustomObject]@{
    email          = $p.Accounts.MicrosoftActiveDirectory.mail;
    voornaam       = $p.Name.NickName
    tussenvoegsel  = GenerateMiddleName -person $p
    achternaam     = GenerateLastName -person $p
    gebruikersnaam = $p.Accounts.MicrosoftActiveDirectory.samaccountname
    externalId     = $aRef
    geslacht       = $gender
}

Try {
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

        if (-Not($dryRun -eq $True)) {
            $null = Invoke-SqliteQuery -Query $query -DataSource $database -SqlParameters $sqlParameters -Verbose:$verbose
        }
        else {
            write-warning "executing: $($query)"
            write-warning "with parameters: $($sqlParameters | convertto-json)"
        }
          
        $success = $true
        $auditLogs.Add([PSCustomObject]@{
                Action  = "UpdateAccount"
                Message = "Account updated for $($account.email) ($($aref))"
                IsError = $false
            }) 
    }
}
catch {
    $success = $false
    $auditLogs.Add([PSCustomObject]@{
            Action  = "UpdateAccount"
            Message = "Failed to update account - $($_)"
            IsError = $true
        })
}
#build up result
$result = [PSCustomObject]@{ 
    Success          = $success;
    AccountReference = $aRef;
    auditLogs        = $auditLogs;
    Account          = $account;
    
    # Optionally return data for use in other systems
    ExportData       = [PSCustomObject]@{
        externalID = $aRef
        email      = $account.email
    };
};

Write-Output $result | ConvertTo-Json -Depth 10