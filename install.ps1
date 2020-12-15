[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bOR [Net.SecurityProtocolType]::Tls12
function Update-SqlitePs51Compatible {
    [CmdletBinding()]

    param(
        [Parameter()]
        [string]
        $version = '1.0.112',
    
        [Parameter()]
        [ValidateSet('linux-x64','osx-x64','win-x64','win-x86')]
        [string]
        $OS
    )
    
    Process {
        write-verbose "Creating build directory"
        New-Item -ItemType directory build
        Set-Location build
    
        $file = "system.data.sqlite.core.$version"

        write-verbose "downloading files from nuget"
        $dl = @{
            uri = "https://www.nuget.org/api/v2/package/System.Data.SQLite.Core/$version"
            outfile = "$file.zip"
        }
        Invoke-WebRequest @dl

        write-verbose "unpacking and copying files to module directory"
        Expand-Archive $dl.outfile

        $InstallPath = (get-module PSSQlite).path.TrimEnd('PSSQLite.psm1')
        copy-item $file/lib/netstandard2.0/System.Data.SQLite.dll $InstallPath/core/$os/
        copy-item $file/runtimes/$os/native/netstandard2.0/SQLite.Interop.dll $InstallPath/core/$os/

        write-verbose "removing build folder"
        Set-location ..
        remove-item ./build -recurse
        write-verbose "complete"

        Write-Warning "Please reimport the module to use the latest files"
    }
}

function Verify-NugetRegistered
{
	[CmdletBinding()]
	Param ()
	if (-not (Get-PackageSource | Where-Object{ $_.Name -eq 'Nuget' }))
	{
		Register-PackageSource -Name Nuget -ProviderName NuGet -Location https://www.nuget.org/api/v2
	}
	else
	{
		Write-Host "Already registered: NuGet."
	};
};

function Verify-SQLiteModuleInstalled
{
	[CmdletBinding()]
	Param ()
	if (-not (Get-Module  | Where-Object{ $_.Name -eq 'PSSQLite' }))
	{
		Install-Module PSSQLite
	}
	else
	{
		Write-Host "Already Installed: PSSQLite."
	};
};

Verify-NugetRegistered
Verify-SQLiteModuleInstalled
import-module PSsqlite
Update-SqlitePs51Compatible -version 1.0.113.1 -OS win-x64 -Verbose
import-module PSsqlite