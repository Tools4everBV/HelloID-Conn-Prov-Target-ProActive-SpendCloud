################################################
# HelloID-Conn-Prov-Target-SpendCloud-Delete
################################################

#region functions
try {
    Import-Module PSSQLite

    $query = "UPDATE persons SET passief = 'Ja' WHERE gebruikersnaam = '$($actionContext.References.Account)'"
    if (-Not($actionContext.DryRun -eq $true)) {
        $null = Invoke-SqliteQuery -Query $query -DataSource $actionContext.Configuration.database
    }
    else {
        Write-warning "Would send: $query"
    }

    $query = "DELETE FROM roles WHERE gebruikersnaam = '$($actionContext.References.Account)'"
    if (-Not($actionContext.DryRun -eq $true)) {
        $null = Invoke-SqliteQuery -Query $query -DataSource $actionContext.Configuration.database
    }
    else {
        Write-warning "Would send: $query"
    }

    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = "DeleteAccount"
            Message = "Account with username [$($actionContext.References.Account)] set to passief = 'Ja'"
            IsError = $false
        })
    $outputContext.Success = $true
}
catch {
    $ex = $PSItem

    $auditMessage = "Error removing data from SQL Lite DB. Error: $($ex.Exception.Message)"
    Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"

    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = "DeleteAccount"
            Message = $auditMessage
            IsError = $false
        })
    $outputContext.Success = $false
}