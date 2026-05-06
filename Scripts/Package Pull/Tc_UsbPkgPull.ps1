

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [int]$TimeoutSeconds = 10,
    [Parameter(Mandatory=$false)]
    [string]$WinSCPPath    = "C:\Program Files (x86)\WinSCP\WinSCP.exe",
    [Parameter(Mandatory=$false)]
    [string]$CerHostPath   = "$PSScriptRoot\CERHOST.exe",
    [Parameter(Mandatory=$false)]
    [string]$AdminUserName = "Administrator",
    [Parameter(Mandatory=$false)]
    [SecureString]$AdminPassword = (ConvertTo-SecureString "1" -AsPlainText -Force),
    [Parameter(Mandatory=$true)]
    [string]$outputFolder = "pkg"
)


$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
[string]$target = "$scriptPath$outputFolder"

function Test-Create-PkgPath{
    [CmdletBinding()]
    param(
        [int]$TimeoutSeconds = 10,
        [switch]$AllowRefresh
    )

    Try{
        if (Test-Path -Path $target) {
            Write-Output "Valid Directory Found: $target"
        }
        else{
            New-Item -Path $target -ItemType Directory -Force -Name $outputFolder | Out-Null
            Write-Output "Created directory: $target"
        }
    }
    Catch {
        Write-Error "Failed to create directory '$target'"
    }
}


function Tc-PkgExport{

    try{
        tcpkg export -o $target -y
    }
    catch{
        Write-Error "Failed to export to: '$target'"
    }
}

function Tc-PkgPull{
    try{
        Write-Output "Starting download at: $target Please Wait..."
        tcpkg download -i "$target\Export.config" -o $target -y
    }
    catch{
        Write-Error "Failed to download to: '$target'"
    }
}


### Entry Point

try{
    Test-Create-PkgPath
    Tc-PkgExport
    Tc-PkgPull
}
catch{
    Write-Error "Fatal error: $_"
}

